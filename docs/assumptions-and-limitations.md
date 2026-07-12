# Assumptions and Limitations

This document lists design assumptions, operational rules, and platform limitations encountered during the development of the Customer Onboarding Tool.

---

## 1. Key Business Assumptions

### 1.1 "Ready for Go-Live" KPI Calculation
- **Assumption**: A customer is defined as "Ready for Go-Live" if and only if:
  1. `Onboarding_Status__c = 'UAT'`
  2. `Go_Live_Date__c` is within the next 7 days, inclusive (i.e. `Go_Live_Date__c >= TODAY AND Go_Live_Date__c <= NEXT_N_DAYS:7`).
- **Rationale**: The business requirements specified UAT status and a go-live date in the next 7 days. Customers in the final `Go-Live` stage itself are considered to have completed their transition, so they are not included in the UAT "ready" pipeline.

### 1.2 "Overdue Task" Status
- **Assumption**: A task is considered overdue if:
  1. `Status__c` is NOT equal to `'Completed'` (i.e. is `Pending` or `In Progress`).
  2. `Due_Date__c` is strictly less than the current date (`TODAY`).
- **Rationale**: Completed tasks are archived/complete and should not generate notifications or late statuses regardless of their historical due date.

### 1.3 Validation Rules
- **Assumption**: `Go_Live_Date__c` is required to be set in the future.
- **Limitation**: During retrofits or when migrating legacy customer records via bulk data loader, past go-live dates will fail insertion unless validation rules are bypassed or inactive.

---

## 2. Technical and Platform Limitations

### 2.1 Salesforce Email Limits
- **Trigger Audits**: The email handler in `OnboardingTriggerHandler` uses `Messaging.SingleEmailMessage` to notify owners on stage changes.
- **Platform Limits**: Salesforce enforces daily single email limits on developer orgs (typically 15 emails per day to external addresses, unlimited to internal users).
- **Bulkification Mitigation**: The trigger handler is fully bulkified. It compiles and groups status change notifications by the owner (standard `User` record). Rather than firing individual messages in a loop, it combines calls and issues them in bulk to optimize governor limit usage.

### 2.2 FLS and Security in Unit Tests
- **Context**: Standard Salesforce Apex unit tests execute under the context of the running user (normally System Administrator). In new scratch/developer orgs, newly created custom fields do not have Field-Level Security (FLS) assigned to the default System Administrator profile.
- **Resolution**: Since the services enforce security via `WITH SECURITY_ENFORCED` and `Security.stripInaccessible`, tests run as default admin would throw permissions exceptions. To test security properly and ensure clean test execution on any CI/CD environment, all unit tests run under a dynamically created standard `User` context assigned with the `Customer_Onboarding_User` permission set using `System.runAs()`.

### 2.3 File Upload File Types
- **LWC Uploader**: The file uploader added to the "Documentation Pending" stage is configured to accept typical document extensions (`.pdf`, `.png`, `.jpg`, `.jpeg`, `.docx`, `.doc`, `.xlsx`, `.xls`, `.csv`).
- **Salesforce Storage Limits**: uploaded files occupy standard Salesforce file storage. In standard sandbox/dev environments, storage limits are small (typically 10-20MB total). Users should upload small test attachments to avoid running out of capacity.

### 2.4 API User Security
- **REST Endpoints**: The custom API endpoints require an active Salesforce OAuth session to be invoked. Anonymous access is blocked by Salesforce security, ensuring that client integrations must authenticate before reading or modifying onboarding data.
