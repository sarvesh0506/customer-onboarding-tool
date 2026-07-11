// Force redeploy comment v1
@IsTest
private class CustomerRestResourceTest {
    
    @IsTest
    static void testGetCustomer() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Rest Cust');
            insert cust;
            
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers/' + cust.Id;
            req.httpMethod = 'GET';
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.getCustomerOrList();
            Test.stopTest();
            
            Assert.areEqual(200, res.statusCode);
            String body = res.responseBody.toString();
            Customer__c result = (Customer__c) JSON.deserialize(body, Customer__c.class);
            Assert.areEqual(cust.Id, result.Id);
        }
    }
    
    @IsTest
    static void testGetCustomerList() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Rest Cust', Onboarding_Status__c = 'New Customer');
            insert cust;
            
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers';
            req.httpMethod = 'GET';
            req.params.put('status', 'New Customer');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.getCustomerOrList();
            Test.stopTest();
            
            Assert.areEqual(200, res.statusCode);
            String body = res.responseBody.toString();
            List<Customer__c> result = (List<Customer__c>) JSON.deserialize(body, List<Customer__c>.class);
            Assert.areEqual(1, result.size());
        }
    }
    
    @IsTest
    static void testGetCustomerNotFound() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers/a00000000000000';
            req.httpMethod = 'GET';
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.getCustomerOrList();
            Test.stopTest();
            
            Assert.areEqual(404, res.statusCode);
        }
    }
    
    @IsTest
    static void testCreateCustomer() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"Name": "New Rest Customer", "Company__c": "Rest Inc"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.createCustomer();
            Test.stopTest();
            
            Assert.areEqual(201, res.statusCode);
            Customer__c created = (Customer__c) JSON.deserialize(res.responseBody.toString(), Customer__c.class);
            Assert.areNotEqual(null, created.Id);
        }
    }
    
    @IsTest
    static void testCreateCustomerFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"Name": "Fail", "Go_Live_Date__c": "not-a-date"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.createCustomer();
            Test.stopTest();
            
            Assert.areEqual(400, res.statusCode);
        }
    }
    
    @IsTest
    static void testUpdateCustomer() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Original Name');
            insert cust;
            
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers/' + cust.Id;
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueOf('{"Name": "Updated Name"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.updateCustomer();
            Test.stopTest();
            
            Assert.areEqual(200, res.statusCode);
            Customer__c updated = (Customer__c) JSON.deserialize(res.responseBody.toString(), Customer__c.class);
            Assert.areEqual('Updated Name', updated.Name);
        }
    }
    
    @IsTest
    static void testUpdateCustomerStatus() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Original Name', Onboarding_Status__c = 'New Customer');
            insert cust;
            
            RestRequest req = new RestRequest();
            req.requestURI = '/onboarding/customers/' + cust.Id + '/status';
            req.httpMethod = 'PATCH';
            req.requestBody = Blob.valueOf('{"status": "UAT", "note": "Stage updated to UAT"}');
            RestContext.request = req;
            
            RestResponse res = new RestResponse();
            RestContext.response = res;
            
            Test.startTest();
            CustomerRestResource.updateCustomer();
            Test.stopTest();
            
            Assert.areEqual(200, res.statusCode);
            Customer__c updated = (Customer__c) JSON.deserialize(res.responseBody.toString(), Customer__c.class);
            Assert.areEqual('UAT', updated.Onboarding_Status__c);
            
            List<Onboarding_Note__c> notes = [SELECT Stage__c, Note__c FROM Onboarding_Note__c WHERE Customer__c = :cust.Id];
            Assert.areEqual(1, notes.size());
            Assert.areEqual('UAT', notes[0].Stage__c);
            Assert.areEqual('Stage updated to UAT', notes[0].Note__c);
        }
    }
}
