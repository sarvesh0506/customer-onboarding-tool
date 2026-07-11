@IsTest
public class TestUtility {
    
    public static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        
        User u = new User(
            Alias = 'tuser',
            Email = 'testuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUserName
        );
        insert u;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Onboarding_User' LIMIT 1];
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );
        
        return u;
    }
}
