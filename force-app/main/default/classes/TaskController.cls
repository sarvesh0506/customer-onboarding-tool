public with sharing class TaskController {
    
    @AuraEnabled
    public static Onboarding_Task__c createTask(Onboarding_Task__c task) {
        try {
            return TaskService.createTask(task);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Onboarding_Task__c updateTask(Onboarding_Task__c task) {
        try {
            return TaskService.updateTask(task);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Onboarding_Task__c> listTasksForCustomer(Id customerId) {
        try {
            return TaskService.listTasksForCustomer(customerId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Onboarding_Task__c> listOverdueTasks() {
        try {
            return TaskService.listOverdueTasks();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
