import { LightningElement, api, track } from 'lwc';
import getCustomer from '@salesforce/apex/CustomerController.getCustomer';
import updateOnboardingStatus from '@salesforce/apex/CustomerController.updateOnboardingStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomerDetails extends LightningElement {
    @api customerId;

    @track customer;
    @track isModalOpen = false;
    @track isEditModalOpen = false;
    @track newStage = '';
    @track notes = '';

    stagesOrder = ['New Customer', 'Documentation Pending', 'Implementation', 'UAT', 'Go-Live'];

    stageOptions = [
        { label: 'New Customer', value: 'New Customer' },
        { label: 'Documentation Pending', value: 'Documentation Pending' },
        { label: 'Implementation', value: 'Implementation' },
        { label: 'UAT', value: 'UAT' },
        { label: 'Go-Live', value: 'Go-Live' }
    ];

    watchCustomerId;

    // Reacting to customerId change
    renderedCallback() {
        if (this.customerId !== this.watchCustomerId) {
            this.watchCustomerId = this.customerId;
            this.fetchCustomerDetails();
        }
    }

    @api
    refresh() {
        return this.fetchCustomerDetails();
    }

    async fetchCustomerDetails() {
        if (!this.customerId) {
            this.customer = null;
            return;
        }

        try {
            this.customer = await getCustomer({ customerId: this.customerId });
            this.newStage = this.customer.Onboarding_Status__c;
        } catch (error) {
            console.error('Error fetching customer details', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Loading Details',
                message: error.body ? error.body.message : 'Unknown error',
                variant: 'error'
            }));
        }
    }

    // Get steps array for path UI
    get steps() {
        if (!this.customer || !this.customer.Onboarding_Status__c) {
            return [];
        }

        const currentStage = this.customer.Onboarding_Status__c;
        const currentIndex = this.stagesOrder.indexOf(currentStage);

        return this.stagesOrder.map((stage, index) => {
            const isCompleted = index < currentIndex;
            const isCurrent = index === currentIndex;
            const isFuture = index > currentIndex;

            let stepClass = 'step ';
            if (isCompleted) stepClass += 'step-completed';
            else if (isCurrent) stepClass += 'step-current';
            else if (isFuture) stepClass += 'step-future';

            return {
                name: stage,
                index: index + 1,
                isCompleted,
                isLast: index === this.stagesOrder.length - 1,
                stepClass
            };
        });
    }

    get ownerName() {
        return this.customer && this.customer.Owner ? this.customer.Owner.Name : 'N/A';
    }

    get completionPercentage() {
        if (!this.customer || !this.customer.Total_Tasks__c || this.customer.Total_Tasks__c === 0) {
            return 0;
        }
        return Math.round((this.customer.Completed_Tasks__c / this.customer.Total_Tasks__c) * 100);
    }

    get isSaveDisabled() {
        return !this.newStage;
    }

    get isDocumentationPending() {
        return this.customer && this.customer.Onboarding_Status__c === 'Documentation Pending';
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.docx', '.doc', '.xlsx', '.xls', '.csv'];
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Upload Successful',
            message: `${uploadedFiles.length} file(s) uploaded successfully.`,
            variant: 'success'
        }));
        this.fetchCustomerDetails();
    }

    openModal() {
        if (this.customer) {
            this.newStage = this.customer.Onboarding_Status__c;
            this.notes = '';
            this.isModalOpen = true;
        }
    }

    closeModal() {
        this.isModalOpen = false;
    }

    openEditModal() {
        this.isEditModalOpen = true;
    }

    closeEditModal() {
        this.isEditModalOpen = false;
    }

    handleEditSuccess() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Customer details updated successfully',
            variant: 'success'
        }));
        this.isEditModalOpen = false;
        
        // Notify parent to refresh sidebar list/dashboard
        this.dispatchEvent(new CustomEvent('statuschange'));
        
        // Refresh local details
        this.fetchCustomerDetails();
    }

    handleNewStageChange(event) {
        this.newStage = event.target.value;
    }

    handleNotesChange(event) {
        this.notes = event.target.value;
    }

    async handleSaveStage() {
        try {
            await updateOnboardingStatus({
                customerId: this.customerId,
                newStatus: this.newStage,
                noteText: this.notes
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `Stage updated to ${this.newStage}`,
                variant: 'success'
            }));

            this.closeModal();
            
            // Dispatch event to parent to refresh other components
            this.dispatchEvent(new CustomEvent('statuschange'));
            
            // Refresh local details
            this.fetchCustomerDetails();
        } catch (error) {
            console.error('Error updating status', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Saving Changes',
                message: error.body ? error.body.message : 'Unknown error',
                variant: 'error'
            }));
        }
    }
}
