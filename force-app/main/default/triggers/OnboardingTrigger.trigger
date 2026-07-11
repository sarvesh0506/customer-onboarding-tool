trigger OnboardingTrigger on Customer__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        OnboardingTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
