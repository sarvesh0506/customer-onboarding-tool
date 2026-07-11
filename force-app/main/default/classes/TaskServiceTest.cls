@IsTest
private class TaskServiceTest {
    
    @IsTest
    static void testCreateTaskSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Test Task',
                Customer__c = cust.Id,
                Status__c = 'Pending',
                Due_Date__c = Date.today().addDays(5),
                Description__c = 'Test Description'
            );
            
            Test.startTest();
            Onboarding_Task__c created = TaskService.createTask(task);
            Test.stopTest();
            
            Assert.areNotEqual(null, created.Id);
            Assert.areEqual('Test Task', created.Name);
        }
    }
    
    @IsTest
    static void testCreateTaskNullFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            try {
                Test.startTest();
                TaskService.createTask(null);
                Test.stopTest();
                Assert.fail('Should throw exception for null record');
            } catch (IllegalArgumentException e) {
                Assert.isTrue(e.getMessage().contains('Task record cannot be null'), 'Expected task record cannot be null message');
            }
        }
    }
    
    @IsTest
    static void testUpdateTaskSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Test Task',
                Customer__c = cust.Id,
                Status__c = 'Pending'
            );
            insert task;
            
            task.Status__c = 'Completed';
            
            Test.startTest();
            Onboarding_Task__c updated = TaskService.updateTask(task);
            Test.stopTest();
            
            Assert.areEqual('Completed', updated.Status__c);
        }
    }
    
    @IsTest
    static void testUpdateTaskFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            try {
                Test.startTest();
                TaskService.updateTask(new Onboarding_Task__c(Name = 'No Id'));
                Test.stopTest();
                Assert.fail('Should throw exception for task without Id');
            } catch (IllegalArgumentException e) {
                Assert.isTrue(e.getMessage().contains('Task record and ID cannot be null'), 'Expected task record and ID cannot be null message');
            }
        }
    }
    
    @IsTest
    static void testListTasksForCustomer() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            Onboarding_Task__c t1 = new Onboarding_Task__c(Name = 'T1', Customer__c = cust.Id, Due_Date__c = Date.today().addDays(1));
            Onboarding_Task__c t2 = new Onboarding_Task__c(Name = 'T2', Customer__c = cust.Id, Due_Date__c = Date.today().addDays(2));
            insert new List<Onboarding_Task__c>{ t1, t2 };
            
            Test.startTest();
            List<Onboarding_Task__c> tasks = TaskService.listTasksForCustomer(cust.Id);
            List<Onboarding_Task__c> emptyTasks = TaskService.listTasksForCustomer(null);
            Test.stopTest();
            
            Assert.areEqual(2, tasks.size());
            Assert.areEqual('T1', tasks[0].Name);
            Assert.areEqual(0, emptyTasks.size());
        }
    }
    
    @IsTest
    static void testListOverdueTasks() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            Onboarding_Task__c normalTask = new Onboarding_Task__c(Name = 'Normal', Customer__c = cust.Id, Due_Date__c = Date.today().addDays(1), Status__c = 'Pending');
            Onboarding_Task__c overdueTask = new Onboarding_Task__c(Name = 'Overdue', Customer__c = cust.Id, Due_Date__c = Date.today().addDays(-2), Status__c = 'Pending');
            Onboarding_Task__c completedOverdue = new Onboarding_Task__c(Name = 'Completed Overdue', Customer__c = cust.Id, Due_Date__c = Date.today().addDays(-2), Status__c = 'Completed');
            insert new List<Onboarding_Task__c>{ normalTask, overdueTask, completedOverdue };
            
            Test.startTest();
            List<Onboarding_Task__c> overdueList = TaskService.listOverdueTasks();
            Test.stopTest();
            
            Assert.areEqual(1, overdueList.size());
            Assert.areEqual('Overdue', overdueList[0].Name);
        }
    }
}
