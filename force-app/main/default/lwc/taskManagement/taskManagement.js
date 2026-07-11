import { LightningElement, api, track } from 'lwc';
import listTasksForCustomer from '@salesforce/apex/TaskController.listTasksForCustomer';
import createTask from '@salesforce/apex/TaskController.createTask';
import updateTask from '@salesforce/apex/TaskController.updateTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TaskManagement extends LightningElement {
    @api customerId;

    @track tasks = [];
    @track isModalOpen = false;

    // Modal Fields
    @track newTaskName = '';
    @track newDueDate = '';
    @track newStatus = 'Pending';
    @track newDescription = '';

    statusOptions = [
        { label: 'Pending', value: 'Pending' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' }
    ];

    watchCustomerId;

    renderedCallback() {
        if (this.customerId !== this.watchCustomerId) {
            this.watchCustomerId = this.customerId;
            this.fetchTasks();
        }
    }

    @api
    refresh() {
        return this.fetchTasks();
    }

    async fetchTasks() {
        if (!this.customerId) {
            this.tasks = [];
            return;
        }

        try {
            const rawTasks = await listTasksForCustomer({ customerId: this.customerId });
            
            // Format dates and add UI helper flags
            const todayStr = new Date().toISOString().substring(0, 10);

            this.tasks = rawTasks.map(tsk => {
                const isCompleted = tsk.Status__c === 'Completed';
                
                // Compare string dates to avoid timezone discrepancies
                const isOverdue = !isCompleted && tsk.Due_Date__c && tsk.Due_Date__c < todayStr;

                let rowClass = 'task-row slds-p-around_medium slds-m-bottom_small ';
                if (isCompleted) rowClass += 'task-completed-row';
                else if (isOverdue) rowClass += 'task-overdue-row';
                else rowClass += 'task-normal-row';

                const assignedName = tsk.Assigned_To__r ? tsk.Assigned_To__r.Name : 'Unassigned';

                return {
                    ...tsk,
                    isCompleted,
                    isOverdue,
                    rowClass,
                    assignedName
                };
            });
        } catch (error) {
            console.error('Error fetching tasks', error);
        }
    }

    get isSaveDisabled() {
        return !this.newTaskName || !this.newDueDate || !this.newStatus;
    }

    openModal() {
        this.newTaskName = '';
        this.newDueDate = new Date().toISOString().substring(0, 10); // Default to today
        this.newStatus = 'Pending';
        this.newDescription = '';
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleFieldChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        if (fieldName === 'taskName') this.newTaskName = fieldValue;
        else if (fieldName === 'dueDate') this.newDueDate = fieldValue;
        else if (fieldName === 'status') this.newStatus = fieldValue;
        else if (fieldName === 'description') this.newDescription = fieldValue;
    }

    async handleSaveTask() {
        try {
            const taskObj = {
                Name: this.newTaskName,
                Customer__c: this.customerId,
                Due_Date__c: this.newDueDate,
                Status__c: this.newStatus,
                Description__c: this.newDescription
            };

            await createTask({ task: taskObj });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Task created successfully',
                variant: 'success'
            }));

            this.closeModal();
            this.dispatchEvent(new CustomEvent('taskchange'));
            this.fetchTasks();
        } catch (error) {
            console.error('Error creating task', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Creating Task',
                message: error.body ? error.body.message : 'Unknown error',
                variant: 'error'
            }));
        }
    }

    async handleStatusToggle(event) {
        const taskId = event.target.dataset.id;
        const checked = event.target.checked;
        const newStatusValue = checked ? 'Completed' : 'In Progress';

        try {
            // Find task record first
            const tsk = this.tasks.find(t => t.Id === taskId);
            if (tsk) {
                const updatedTaskObj = {
                    Id: taskId,
                    Status__c: newStatusValue
                };
                
                await updateTask({ task: updatedTaskObj });

                this.dispatchEvent(new CustomEvent('taskchange'));
                this.fetchTasks();
            }
        } catch (error) {
            console.error('Error updating task status', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Updating Task',
                message: error.body ? error.body.message : 'Unknown error',
                variant: 'error'
            }));
        }
    }
}
