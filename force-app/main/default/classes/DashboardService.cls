public with sharing class DashboardService {
    
    public static Integer getTotalCustomers() {
        return [SELECT COUNT() FROM Customer__c WITH SECURITY_ENFORCED];
    }
    
    public static Map<String, Integer> getCustomersByStage() {
        Map<String, Integer> stageCounts = new Map<String, Integer>{
            'New Customer' => 0,
            'Documentation Pending' => 0,
            'Implementation' => 0,
            'UAT' => 0,
            'Go Live' => 0,
            'Completed' => 0
        };
        
        List<AggregateResult> results = [
            SELECT Onboarding_Status__c stage, COUNT(Id) cnt 
            FROM Customer__c 
            WITH SECURITY_ENFORCED 
            GROUP BY Onboarding_Status__c
        ];
        
        for (AggregateResult ar : results) {
            String stage = (String) ar.get('stage');
            Integer count = (Integer) ar.get('cnt');
            if (stage != null) {
                stageCounts.put(stage, count);
            }
        }
        return stageCounts;
    }
    
    public static Integer getOverdueTaskCount() {
        return [
            SELECT COUNT() 
            FROM Onboarding_Task__c 
            WHERE Status__c != 'Completed' AND Due_Date__c < TODAY
            WITH SECURITY_ENFORCED
        ];
    }
    
    public static Integer getReadyForGoLiveCount() {
        // Assumption: "Ready for Go-Live" count is defined as Onboarding_Status__c = 'UAT'
        // and Go_Live_Date__c is within the upcoming 7 days (including today).
        // SOQL query leverages Go_Live_Date__c >= TODAY AND Go_Live_Date__c <= NEXT_N_DAYS:7.
        return [
            SELECT COUNT() 
            FROM Customer__c 
            WHERE Onboarding_Status__c = 'UAT' 
            AND Go_Live_Date__c >= TODAY 
            AND Go_Live_Date__c <= NEXT_N_DAYS:7
            WITH SECURITY_ENFORCED
        ];
    }
}
