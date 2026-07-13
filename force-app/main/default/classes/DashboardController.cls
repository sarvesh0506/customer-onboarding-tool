public with sharing class DashboardController {
    
    @AuraEnabled
    public static Integer getTotalCustomers() {
        try {
            return DashboardService.getTotalCustomers();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, Integer> getCustomersByStage() {
        try {
            return DashboardService.getCustomersByStage();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Integer getOverdueTaskCount() {
        try {
            return DashboardService.getOverdueTaskCount();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Integer getReadyForGoLiveCount() {
        try {
            return DashboardService.getReadyForGoLiveCount();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
