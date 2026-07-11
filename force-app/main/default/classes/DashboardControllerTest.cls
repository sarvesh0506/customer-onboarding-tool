@IsTest
private class DashboardControllerTest {
    
    @IsTest
    static void testControllerMethods() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c c1 = new Customer__c(Name = 'C1', Onboarding_Status__c = 'New Customer');
            insert c1;
            
            Test.startTest();
            Integer total = DashboardController.getTotalCustomers();
            Map<String, Integer> stages = DashboardController.getCustomersByStage();
            Integer overdue = DashboardController.getOverdueTaskCount();
            Integer ready = DashboardController.getReadyForGoLiveCount();
            Test.stopTest();
            
            Assert.areEqual(1, total);
            Assert.areEqual(1, stages.get('New Customer'));
            Assert.areEqual(0, overdue);
            Assert.areEqual(0, ready);
        }
    }
}
