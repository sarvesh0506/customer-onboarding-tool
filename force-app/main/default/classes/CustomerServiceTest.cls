@IsTest
private class CustomerServiceTest {
    
    @IsTest
    static void testCreateCustomerSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(
                Name = 'Test Customer',
                Company__c = 'Test Company',
                Email__c = 'test@example.com',
                Phone__c = '1234567890'
            );
            
            Test.startTest();
            Customer__c created = CustomerService.createCustomer(cust);
            Test.stopTest();
            
            Assert.areNotEqual(null, created.Id, 'Id should not be null');
            Assert.areEqual('Test Customer', created.Name, 'Name should match');
        }
    }
    
    @IsTest
    static void testCreateCustomerNullFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            try {
                Test.startTest();
                CustomerService.createCustomer(null);
                Test.stopTest();
                Assert.fail('Should throw an exception for null record');
            } catch (IllegalArgumentException e) {
                Assert.isTrue(e.getMessage().contains('Customer record cannot be null'), 'Expected customer record cannot be null message');
            }
        }
    }
    
    @IsTest
    static void testUpdateCustomerSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            cust.Company__c = 'Updated Company';
            
            Test.startTest();
            Customer__c updated = CustomerService.updateCustomer(cust);
            Test.stopTest();
            
            Assert.areEqual('Updated Company', updated.Company__c);
        }
    }
    
    @IsTest
    static void testUpdateCustomerFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            try {
                Test.startTest();
                CustomerService.updateCustomer(new Customer__c(Name = 'No Id'));
                Test.stopTest();
                Assert.fail('Should throw exception when updating without Id');
            } catch (IllegalArgumentException e) {
                Assert.isTrue(e.getMessage().contains('Customer record and ID cannot be null'), 'Expected customer record and ID cannot be null message');
            }
        }
    }
    
    @IsTest
    static void testGetCustomerSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer');
            insert cust;
            
            Test.startTest();
            Customer__c retrieved = CustomerService.getCustomer(cust.Id);
            Test.stopTest();
            
            Assert.areEqual(cust.Id, retrieved.Id);
        }
    }
    
    @IsTest
    static void testGetCustomerNull() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Test.startTest();
            Customer__c retrieved = CustomerService.getCustomer(null);
            Test.stopTest();
            Assert.areEqual(null, retrieved);
        }
    }
    
    @IsTest
    static void testListCustomers() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust1 = new Customer__c(Name = 'Alpha Corp', Company__c = 'Alpha', Onboarding_Status__c = 'New Customer');
            Customer__c cust2 = new Customer__c(Name = 'Beta Inc', Company__c = 'Beta', Onboarding_Status__c = 'UAT');
            insert new List<Customer__c>{ cust1, cust2 };
            
            Test.startTest();
            List<Customer__c> resultSearch = CustomerService.listCustomers(new Map<String, Object>{ 'searchTerm' => 'Alpha' });
            List<Customer__c> resultStatus = CustomerService.listCustomers(new Map<String, Object>{ 'status' => 'UAT' });
            List<Customer__c> resultAll = CustomerService.listCustomers(null);
            Test.stopTest();
            
            Assert.areEqual(1, resultSearch.size());
            Assert.areEqual('Alpha Corp', resultSearch[0].Name);
            Assert.areEqual(1, resultStatus.size());
            Assert.areEqual('Beta Inc', resultStatus[0].Name);
            Assert.areEqual(2, resultAll.size());
        }
    }
    
    @IsTest
    static void testUpdateOnboardingStatus() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'New Customer');
            insert cust;
            
            Test.startTest();
            CustomerService.updateOnboardingStatus(cust.Id, 'Implementation', 'Moving to implementation phase');
            Test.stopTest();
            
            Customer__c updated = [SELECT Onboarding_Status__c FROM Customer__c WHERE Id = :cust.Id];
            Assert.areEqual('Implementation', updated.Onboarding_Status__c);
            
            List<Onboarding_Note__c> notes = [SELECT Stage__c, Note__c FROM Onboarding_Note__c WHERE Customer__c = :cust.Id];
            Assert.areEqual(1, notes.size());
            Assert.areEqual('Implementation', notes[0].Stage__c);
            Assert.areEqual('Moving to implementation phase', notes[0].Note__c);
        }
    }
    
    @IsTest
    static void testUpdateOnboardingStatusCompletedSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'UAT');
            insert cust;
            
            // Create a completed task
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Completed Task',
                Customer__c = cust.Id,
                Status__c = 'Completed',
                Due_Date__c = Date.today()
            );
            insert task;
            
            Test.startTest();
            CustomerService.updateOnboardingStatus(cust.Id, 'Completed', 'onboarding finished');
            Test.stopTest();
            
            Customer__c updated = [SELECT Onboarding_Status__c FROM Customer__c WHERE Id = :cust.Id];
            Assert.areEqual('Completed', updated.Onboarding_Status__c);
        }
    }
    
    @IsTest
    static void testUpdateOnboardingStatusCompletedFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'UAT');
            insert cust;
            
            // Create an incomplete task
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Pending Task',
                Customer__c = cust.Id,
                Status__c = 'Pending',
                Due_Date__c = Date.today()
            );
            insert task;
            
            try {
                Test.startTest();
                CustomerService.updateOnboardingStatus(cust.Id, 'Completed', 'onboarding finished');
                Test.stopTest();
                Assert.fail('Should fail due to incomplete tasks');
            } catch (IllegalArgumentException e) {
                Assert.isTrue(e.getMessage().contains('Still tasks are yet to complete'), 'Expected tasks yet to complete validation message');
            }
        }
    }

    @IsTest
    static void testUpdateOnboardingStatusGoLiveSuccess() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'UAT');
            insert cust;
            
            // Create a completed task
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Completed Task',
                Customer__c = cust.Id,
                Status__c = 'Completed',
                Due_Date__c = Date.today()
            );
            insert task;
            
            Test.startTest();
            CustomerService.updateOnboardingStatus(cust.Id, 'Go Live', 'ready to go live');
            Test.stopTest();
            
            Customer__c updated = [SELECT Onboarding_Status__c FROM Customer__c WHERE Id = :cust.Id];
            Assert.areEqual('Go Live', updated.Onboarding_Status__c);
        }
    }
    
    @IsTest
    static void testUpdateOnboardingStatusGoLiveFailure() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'UAT');
            insert cust;
            
            // Create an incomplete task
            Onboarding_Task__c task = new Onboarding_Task__c(
                Name = 'Pending Task',
                Customer__c = cust.Id,
                Status__c = 'Pending',
                Due_Date__c = Date.today()
            );
            insert task;
            
            try {
                Test.startTest();
                CustomerService.updateOnboardingStatus(cust.Id, 'Go Live', 'ready to go live');
                Test.stopTest();
                Assert.fail('Should fail due to incomplete tasks');
            } catch (IllegalArgumentException e) {
                Assert.isTrue(e.getMessage().contains('Still tasks are yet to complete'), 'Expected tasks yet to complete validation message');
            }
        }
    }
}
