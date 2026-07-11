public with sharing class OnboardingTriggerHandler {
    
    public static void handleAfterUpdate(List<Customer__c> newRecords, Map<Id, Customer__c> oldMap) {
        List<Customer__c> statusChangedCustomers = new List<Customer__c>();
        Set<Id> ownerIds = new Set<Id>();
        
        for (Customer__c cust : newRecords) {
            Customer__c oldCust = oldMap.get(cust.Id);
            if (cust.Onboarding_Status__c != oldCust.Onboarding_Status__c) {
                statusChangedCustomers.add(cust);
                ownerIds.add(cust.OwnerId);
            }
        }
        
        if (statusChangedCustomers.isEmpty()) {
            return;
        }
        
        Map<Id, User> ownersMap = new Map<Id, User>([
            SELECT Id, Email, Name 
            FROM User 
            WHERE Id IN :ownerIds
        ]);
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Customer__c cust : statusChangedCustomers) {
            User owner = ownersMap.get(cust.OwnerId);
            if (owner != null && String.isNotBlank(owner.Email)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{ owner.Email });
                mail.setSubject('Customer Onboarding Stage Changed - ' + cust.Name);
                
                String body = 'Hi ' + owner.Name + ',\n\n' +
                    'The onboarding status of the customer record "' + cust.Name + '" has changed.\n\n' +
                    'Details:\n' +
                    '- Customer Name: ' + cust.Name + '\n' +
                    '- New Status: ' + cust.Onboarding_Status__c + '\n' +
                    '- Previous Status: ' + oldMap.get(cust.Id).Onboarding_Status__c + '\n\n' +
                    'Please review the record in Salesforce.\n\n' +
                    'Best regards,\n' +
                    'Customer Onboarding System';
                
                mail.setPlainTextBody(body);
                emails.add(mail);
            }
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
