import { LightningElement, api, track } from 'lwc';
import getTotalCustomers from '@salesforce/apex/DashboardController.getTotalCustomers';
import getOverdueTaskCount from '@salesforce/apex/DashboardController.getOverdueTaskCount';
import getReadyForGoLiveCount from '@salesforce/apex/DashboardController.getReadyForGoLiveCount';
import getCustomersByStage from '@salesforce/apex/DashboardController.getCustomersByStage';

export default class OnboardingDashboard extends LightningElement {
    @track totalCustomers = 0;
    @track overdueTasks = 0;
    @track readyForGoLive = 0;
    @track stageData = [];

    // Predefined stages order
    stagesOrder = ['New Customer', 'Documentation Pending', 'Implementation', 'UAT', 'Go-Live'];

    connectedCallback() {
        this.fetchMetrics();
    }

    @api
    refresh() {
        return this.fetchMetrics();
    }

    async fetchMetrics() {
        try {
            const [total, overdue, ready, stagesMap] = await Promise.all([
                getTotalCustomers(),
                getOverdueTaskCount(),
                getReadyForGoLiveCount(),
                getCustomersByStage()
            ]);

            this.totalCustomers = total || 0;
            this.overdueTasks = overdue || 0;
            this.readyForGoLive = ready || 0;

            // Formulate stage chart data
            const tempStageData = [];
            this.stagesOrder.forEach(stageName => {
                const count = stagesMap[stageName] || 0;
                const percentage = this.totalCustomers > 0 ? Math.round((count / this.totalCustomers) * 100) : 0;
                
                // Color codes for stages to make them visually distinct
                let barColor = '#4f46e5'; // Indigo
                if (stageName === 'New Customer') barColor = '#6b7280'; // Gray
                else if (stageName === 'Documentation Pending') barColor = '#f59e0b'; // Amber
                else if (stageName === 'Implementation') barColor = '#3b82f6'; // Blue
                else if (stageName === 'UAT') barColor = '#8b5cf6'; // Purple
                else if (stageName === 'Go-Live') barColor = '#10b981'; // Green

                tempStageData.push({
                    name: stageName,
                    count: count,
                    percentage: percentage,
                    barStyle: `width: ${percentage}%; background-color: ${barColor};`
                });
            });

            this.stageData = tempStageData;
        } catch (error) {
            console.error('Error fetching dashboard metrics', error);
        }
    }
}
