@IsTest
private class OnboardingTriggerHandlerTest {
    
    @IsTest
    static void testStatusChangeTriggersEmail() {
        Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'New Customer');
        insert cust;
        
        Test.startTest();
        cust.Onboarding_Status__c = 'Documentation Pending';
        update cust;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        Assert.areEqual(1, emailInvocations, 'One email invocation should have occurred');
    }
    
    @IsTest
    static void testNoStatusChangeNoEmail() {
        Customer__c cust = new Customer__c(Name = 'Test Customer', Onboarding_Status__c = 'New Customer');
        insert cust;
        
        Test.startTest();
        cust.Company__c = 'New Company Name';
        update cust;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        Assert.areEqual(0, emailInvocations, 'No email invocation should occur when status is unchanged');
    }
}
