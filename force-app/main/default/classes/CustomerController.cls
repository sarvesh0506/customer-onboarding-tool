public with sharing class CustomerController {
    
    @AuraEnabled
    public static Customer__c createCustomer(Customer__c record) {
        try {
            return CustomerService.createCustomer(record);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Customer__c updateCustomer(Customer__c record) {
        try {
            return CustomerService.updateCustomer(record);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Customer__c getCustomer(Id customerId) {
        try {
            return CustomerService.getCustomer(customerId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Customer__c> listCustomers(String searchTerm, String status) {
        try {
            Map<String, Object> filters = new Map<String, Object>();
            if (String.isNotBlank(searchTerm)) {
                filters.put('searchTerm', searchTerm);
            }
            if (String.isNotBlank(status)) {
                filters.put('status', status);
            }
            return CustomerService.listCustomers(filters);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateOnboardingStatus(Id customerId, String newStatus, String noteText) {
        try {
            CustomerService.updateOnboardingStatus(customerId, newStatus, noteText);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
