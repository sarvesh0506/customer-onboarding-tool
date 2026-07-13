import { LightningElement, api, track } from 'lwc';
import listCustomers from '@salesforce/apex/CustomerController.listCustomers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomerList extends LightningElement {
    @api selectedCustomerId;

    @track customers = [];
    @track searchTerm = '';
    @track selectedStage = '';
    @track isCreateModalOpen = false;

    delayTimeout;

    stageOptions = [
        { label: 'All Stages', value: '' },
        { label: 'New Customer', value: 'New Customer' },
        { label: 'Documentation Pending', value: 'Documentation Pending' },
        { label: 'Implementation', value: 'Implementation' },
        { label: 'UAT', value: 'UAT' },
        { label: 'Go Live', value: 'Go Live' },
        { label: 'Completed', value: 'Completed' }
    ];

    connectedCallback() {
        this.fetchCustomers();
    }

    @api
    refresh(selectFirstIfEmpty = false) {
        return this.fetchCustomers(selectFirstIfEmpty);
    }

    async fetchCustomers(selectFirstIfEmpty = false) {
        try {
            const rawCustomers = await listCustomers({
                searchTerm: this.searchTerm,
                status: this.selectedStage
            });

            this.customers = rawCustomers.map(cust => {
                // Determine Initials for avatar
                const initials = cust.Name ? cust.Name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() : '??';

                // Determine Badge CSS Class
                let badgeClass = 'status-badge ';
                if (cust.Onboarding_Status__c === 'New Customer') badgeClass += 'badge-gray';
                else if (cust.Onboarding_Status__c === 'Documentation Pending') badgeClass += 'badge-amber';
                else if (cust.Onboarding_Status__c === 'Implementation') badgeClass += 'badge-blue';
                else if (cust.Onboarding_Status__c === 'UAT') badgeClass += 'badge-purple';
                else if (cust.Onboarding_Status__c === 'Go Live') badgeClass += 'badge-green';
                else if (cust.Onboarding_Status__c === 'Completed') badgeClass += 'badge-green';

                // Determine Selected Row Class
                const isSelected = cust.Id === this.selectedCustomerId;
                const rowClass = `customer-row slds-p-around_small ${isSelected ? 'row-selected' : ''}`;

                return {
                    ...cust,
                    initials,
                    badgeClass,
                    rowClass
                };
            });

            // If requested to select the first customer and nothing is currently selected, select the first
            if (selectFirstIfEmpty && this.customers.length > 0 && !this.selectedCustomerId) {
                this.selectCustomer(this.customers[0].Id);
            }
        } catch (error) {
            console.error('Error fetching customer list', error);
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.fetchCustomers();
        }, 300);
    }

    handleStageChange(event) {
        this.selectedStage = event.target.value;
        this.fetchCustomers();
    }

    handleCustomerClick(event) {
        const customerId = event.currentTarget.dataset.id;
        this.selectCustomer(customerId);
    }

    selectCustomer(customerId) {
        this.selectedCustomerId = customerId;
        
        // Refresh classes
        this.customers = this.customers.map(c => ({
            ...c,
            rowClass: `customer-row slds-p-around_small ${c.Id === customerId ? 'row-selected' : ''}`
        }));

        this.dispatchEvent(new CustomEvent('customerselect', {
            detail: { customerId }
        }));
    }

    openCreateModal() {
        this.isCreateModalOpen = true;
    }

    closeCreateModal() {
        this.isCreateModalOpen = false;
    }

    handleCreateSuccess(event) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Customer created successfully',
            variant: 'success'
        }));
        
        this.isCreateModalOpen = false;
        
        // Notify parent to refresh dashboard numbers
        this.dispatchEvent(new CustomEvent('customercreate'));
        
        const newCustomerId = event.detail.id;
        this.selectedCustomerId = newCustomerId;
        this.fetchCustomers().then(() => {
            this.selectCustomer(newCustomerId);
        });
    }
}
