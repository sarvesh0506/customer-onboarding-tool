// Force redeploy comment v1
public with sharing class CustomerService {
    
    public static Customer__c createCustomer(Customer__c record) {
        if (record == null) {
            throw new IllegalArgumentException('Customer record cannot be null');
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<Customer__c>{ record });
        List<Customer__c> strippedRecords = (List<Customer__c>) decision.getRecords();
        
        if (strippedRecords.isEmpty()) {
            throw new IllegalArgumentException('Operation failed due to insufficient permissions');
        }
        
        insert strippedRecords;
        return strippedRecords[0];
    }
    
    public static Customer__c updateCustomer(Customer__c record) {
        if (record == null || record.Id == null) {
            throw new IllegalArgumentException('Customer record and ID cannot be null');
        }
        
        SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, new List<Customer__c>{ record });
        List<Customer__c> strippedRecords = (List<Customer__c>) decision.getRecords();
        
        if (strippedRecords.isEmpty()) {
            throw new IllegalArgumentException('Operation failed due to insufficient permissions');
        }
        
        update strippedRecords;
        return strippedRecords[0];
    }
    
    public static Customer__c getCustomer(Id customerId) {
        if (customerId == null) {
            return null;
        }
        
        List<Customer__c> customers = [
            SELECT Id, Name, Company__c, Email__c, Phone__c, Industry__c, Customer_Type__c, OwnerId, Owner.Name, Onboarding_Status__c, Go_Live_Date__c, Total_Tasks__c, Completed_Tasks__c 
            FROM Customer__c 
            WHERE Id = :customerId 
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        
        if (customers.isEmpty()) {
            throw new QueryException('Customer record not found');
        }
        return customers[0];
    }
    
    public static List<Customer__c> listCustomers(Map<String, Object> filters) {
        String query = 'SELECT Id, Name, Company__c, Email__c, Phone__c, Industry__c, Customer_Type__c, OwnerId, Owner.Name, Onboarding_Status__c, Go_Live_Date__c, Total_Tasks__c, Completed_Tasks__c FROM Customer__c';
        List<String> conditions = new List<String>();
        
        String searchTerm = '';
        String status = '';
        
        if (filters != null) {
            if (filters.containsKey('searchTerm') && filters.get('searchTerm') != null) {
                searchTerm = String.escapeSingleQuotes((String) filters.get('searchTerm')).trim();
            }
            if (filters.containsKey('status') && filters.get('status') != null) {
                status = String.escapeSingleQuotes((String) filters.get('status')).trim();
            }
        }
        
        if (String.isNotBlank(searchTerm)) {
            String likeTerm = '%' + searchTerm + '%';
            conditions.add('(Name LIKE :likeTerm OR Company__c LIKE :likeTerm OR Email__c LIKE :likeTerm)');
        }
        
        if (String.isNotBlank(status)) {
            conditions.add('Onboarding_Status__c = :status');
        }
        
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        query += ' WITH SECURITY_ENFORCED ORDER BY Name ASC';
        
        return (List<Customer__c>) Database.query(query);
    }
    
    public static void updateOnboardingStatus(Id customerId, String newStatus, String noteText) {
        if (customerId == null || String.isBlank(newStatus)) {
            throw new IllegalArgumentException('Customer ID and new status are required');
        }
        
        if (newStatus == 'Go Live' || newStatus == 'Completed') {
            Integer incompleteTasks = [
                SELECT count() 
                FROM Onboarding_Task__c 
                WHERE Customer__c = :customerId 
                AND Status__c != 'Completed'
                WITH SECURITY_ENFORCED
            ];
            if (incompleteTasks > 0) {
                throw new IllegalArgumentException('Still tasks are yet to complete. You can update to ' + newStatus + ' after completing all tasks.');
            }
        }
        
        Customer__c customer = getCustomer(customerId);
        customer.Onboarding_Status__c = newStatus;
        
        Onboarding_Note__c note = new Onboarding_Note__c(
            Customer__c = customerId,
            Stage__c = newStatus,
            Note__c = noteText
        );
        
        Savepoint sp = Database.setSavepoint();
        try {
            updateCustomer(customer);
            
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, new List<Onboarding_Note__c>{ note });
            List<Onboarding_Note__c> strippedNotes = (List<Onboarding_Note__c>) decision.getRecords();
            insert strippedNotes;
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }
}
