@IsTest
private class DashboardServiceTest {
    
    @IsTest
    static void testDashboardMetrics() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c c1 = new Customer__c(Name = 'C1', Onboarding_Status__c = 'New Customer');
            Customer__c c2 = new Customer__c(Name = 'C2', Onboarding_Status__c = 'UAT', Go_Live_Date__c = Date.today().addDays(3));
            Customer__c c3 = new Customer__c(Name = 'C3', Onboarding_Status__c = 'UAT', Go_Live_Date__c = Date.today().addDays(10));
            insert new List<Customer__c>{ c1, c2, c3 };
            
            Onboarding_Task__c overdueTask = new Onboarding_Task__c(
                Name = 'Overdue Task',
                Customer__c = c1.Id,
                Status__c = 'Pending',
                Due_Date__c = Date.today().addDays(-2)
            );
            Onboarding_Task__c normalTask = new Onboarding_Task__c(
                Name = 'Normal Task',
                Customer__c = c1.Id,
                Status__c = 'Pending',
                Due_Date__c = Date.today().addDays(2)
            );
            insert new List<Onboarding_Task__c>{ overdueTask, normalTask };
            
            Test.startTest();
            Integer totalCustomers = DashboardService.getTotalCustomers();
            Map<String, Integer> stageCounts = DashboardService.getCustomersByStage();
            Integer overdueCount = DashboardService.getOverdueTaskCount();
            Integer readyCount = DashboardService.getReadyForGoLiveCount();
            Test.stopTest();
            
            Assert.areEqual(3, totalCustomers);
            Assert.areEqual(1, stageCounts.get('New Customer'));
            Assert.areEqual(2, stageCounts.get('UAT'));
            Assert.areEqual(0, stageCounts.get('Implementation'));
            Assert.areEqual(1, overdueCount);
            Assert.areEqual(1, readyCount, 'Only C2 is UAT and within upcoming 7 days');
        }
    }
}
