import { LightningElement, track } from 'lwc';

export default class OnboardingApp extends LightningElement {
    @track selectedCustomerId;

    handleCustomerSelect(event) {
        this.selectedCustomerId = event.detail.customerId;
    }

    handleStatusChange() {
        // Refresh dashboard (KPIs and stage breakdown)
        const dashboard = this.template.querySelector('.dashboard-comp');
        if (dashboard) {
            dashboard.refresh();
        }

        // Refresh list to update status badges
        const list = this.template.querySelector('.list-comp');
        if (list) {
            list.refresh();
        }
    }

    handleTaskChange() {
        // Refresh customer details (to update completed task counts and percentage)
        const details = this.template.querySelector('.details-comp');
        if (details) {
            details.refresh();
        }

        // Refresh dashboard (in case overdue task count changed)
        const dashboard = this.template.querySelector('.dashboard-comp');
        if (dashboard) {
            dashboard.refresh();
        }
    }

    handleGlobalRefresh() {
        // Refresh everything
        const dashboard = this.template.querySelector('.dashboard-comp');
        if (dashboard) dashboard.refresh();

        const list = this.template.querySelector('.list-comp');
        if (list) list.refresh();

        const details = this.template.querySelector('.details-comp');
        if (details) details.refresh();

        const tasks = this.template.querySelector('.tasks-comp');
        if (tasks) tasks.refresh();
    }
}
