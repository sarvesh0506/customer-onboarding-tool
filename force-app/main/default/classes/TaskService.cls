// Force redeploy comment v1
public with sharing class TaskService {
    
    public static Onboarding_Task__c createTask(Onboarding_Task__c task) {
        if (task == null) {
            throw new IllegalArgumentException('Task record cannot be null');
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<Onboarding_Task__c>{ task });
        List<Onboarding_Task__c> strippedRecords = (List<Onboarding_Task__c>) decision.getRecords();
        
        if (strippedRecords.isEmpty()) {
            throw new IllegalArgumentException('Operation failed due to insufficient permissions');
        }
        
        insert strippedRecords;
        return strippedRecords[0];
    }
    
    public static Onboarding_Task__c updateTask(Onboarding_Task__c task) {
        if (task == null || task.Id == null) {
            throw new IllegalArgumentException('Task record and ID cannot be null');
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Onboarding_Task__c>{ task });
        List<Onboarding_Task__c> strippedRecords = (List<Onboarding_Task__c>) decision.getRecords();
        
        if (strippedRecords.isEmpty()) {
            throw new IllegalArgumentException('Operation failed due to insufficient permissions');
        }
        
        update strippedRecords;
        return strippedRecords[0];
    }
    
    public static List<Onboarding_Task__c> listTasksForCustomer(Id customerId) {
        if (customerId == null) {
            return new List<Onboarding_Task__c>();
        }
        
        return [
            SELECT Id, Name, Customer__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Due_Date__c, Description__c 
            FROM Onboarding_Task__c 
            WHERE Customer__c = :customerId 
            WITH SECURITY_ENFORCED
            ORDER BY Due_Date__c ASC
        ];
    }
    
    public static List<Onboarding_Task__c> listOverdueTasks() {
        return [
            SELECT Id, Name, Customer__c, Customer__r.Name, Assigned_To__c, Assigned_To__r.Name, Status__c, Due_Date__c, Description__c 
            FROM Onboarding_Task__c 
            WHERE Status__c != 'Completed' AND Due_Date__c < TODAY 
            WITH SECURITY_ENFORCED
            ORDER BY Due_Date__c ASC
        ];
    }
}
