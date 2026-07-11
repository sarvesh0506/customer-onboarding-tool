@IsTest
private class TaskControllerTest {
    
    @IsTest
    static void testControllerMethods() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Controller Customer');
            insert cust;
            
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Controller Task',
                Customer__c = cust.Id,
                Status__c = 'Pending',
                Due_Date__c = Date.today().addDays(-1)
            );
            
            Test.startTest();
            Onboarding_Task__c created = TaskController.createTask(task);
            created.Description__c = 'Controller Description';
            Onboarding_Task__c updated = TaskController.updateTask(created);
            List<Onboarding_Task__c> listed = TaskController.listTasksForCustomer(cust.Id);
            List<Onboarding_Task__c> overdue = TaskController.listOverdueTasks();
            Test.stopTest();
            
            Assert.areNotEqual(null, created.Id);
            Assert.areEqual('Controller Description', updated.Description__c);
            Assert.areEqual(1, listed.size());
            Assert.areEqual(1, overdue.size());
        }
    }
    
    @IsTest
    static void testControllerErrors() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            try {
                TaskController.createTask(null);
                Assert.fail('Expected exception');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage() != null);
            }
            
            try {
                TaskController.updateTask(null);
                Assert.fail('Expected exception');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage() != null);
            }
        }
    }
}
