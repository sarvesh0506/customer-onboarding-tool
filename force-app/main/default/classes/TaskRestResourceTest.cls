@IsTest
private class TaskRestResourceTest {
    
    @IsTest
    static void testCreateTask() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/tasks';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"Name": "Rest Task", "Customer__c": "' + cust.Id + '", "Status__c": "Pending"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            TaskRestResource.createTask();
            Test.stopTest();
            
            Assert.areEqual(201, res.statusCode);
            Onboarding_Task__c created = (Onboarding_Task__c) JSON.deserialize(res.responseBody.toString(), Onboarding_Task__c.class);
            Assert.areNotEqual(null, created.Id);
        }
    }
    
    @IsTest
    static void testCreateTaskFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/tasks';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"InvalidField": "Data"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            TaskRestResource.createTask();
            Test.stopTest();
            
            Assert.areEqual(400, res.statusCode);
        }
    }
    
    @IsTest
    static void testUpdateTask() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            Onboarding_Task__c task = new Onboarding_Task__c(Name = 'Original Task', Customer__c = cust.Id, Status__c = 'Pending');
            insert task;
            
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/tasks/' + task.Id;
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueOf('{"Status__c": "Completed"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            TaskRestResource.updateTask();
            Test.stopTest();
            
            Assert.areEqual(200, res.statusCode);
            Onboarding_Task__c updated = (Onboarding_Task__c) JSON.deserialize(res.responseBody.toString(), Onboarding_Task__c.class);
            Assert.areEqual('Completed', updated.Status__c);
        }
    }
    
    @IsTest
    static void testUpdateTaskNotFound() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/tasks/a00000000000000';
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueOf('{"Status__c": "Completed"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            TaskRestResource.updateTask();
            Test.stopTest();
            
            Assert.areEqual(404, res.statusCode);
        }
    }
}
