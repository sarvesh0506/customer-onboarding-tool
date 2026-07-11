@IsTest
private class CustomerControllerTest {
    
    @IsTest
    static void testControllerMethods() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            Customer__c cust = new Customer__c(Name = 'Controller Customer');
            
            Test.startTest();
            Customer__c created = CustomerController.createCustomer(cust);
            created.Company__c = 'Controller Company';
            Customer__c updated = CustomerController.updateCustomer(created);
            Customer__c retrieved = CustomerController.getCustomer(updated.Id);
            List<Customer__c> listed = CustomerController.listCustomers('Controller', null);
            CustomerController.updateOnboardingStatus(updated.Id, 'UAT', 'Test notes');
            Test.stopTest();
            
            Assert.areNotEqual(null, created.Id);
            Assert.areEqual('Controller Company', updated.Company__c);
            Assert.areEqual(updated.Id, retrieved.Id);
            Assert.areEqual(1, listed.size());
            
            Customer__c finalRecord = [SELECT Onboarding_Status__c FROM Customer__c WHERE Id = :updated.Id];
            Assert.areEqual('UAT', finalRecord.Onboarding_Status__c);
        }
    }
    
    @IsTest
    static void testControllerErrors() {
        User u = TestUtility.createTestUser();
        System.runAs(u) {
            try {
                CustomerController.createCustomer(null);
                Assert.fail('Expected exception');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage() != null);
            }
            
            try {
                CustomerController.updateCustomer(null);
                Assert.fail('Expected exception');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage() != null);
            }
        }
    }
}
