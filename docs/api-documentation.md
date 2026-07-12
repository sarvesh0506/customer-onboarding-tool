# REST API Documentation: Customer Onboarding Portal

All API routes are exposed via Salesforce REST Apex. Endpoints are relative to the Salesforce instance URL:
`/services/apexrest/onboarding`

---

## 1. Customer Endpoints

### 1.1 List Customers
* **URL**: `/onboarding/customers`
* **Method**: `GET`
* **Query Parameters**:
  * `status` (Optional): Filter by onboarding status (e.g. `New Customer`, `UAT`).
* **Response**: `200 OK`
* **Response Body**:
```json
[
  {
    "Id": "a00fj00000X1234EAB",
    "Name": "Apex Corp",
    "Company__c": "Apex Enterprises",
    "Email__c": "info@apex.com",
    "Phone__c": "+1 (555) 123-4567",
    "Industry__c": "Technology",
    "Customer_Type__c": "Enterprise",
    "Onboarding_Status__c": "New Customer",
    "Go_Live_Date__c": "2026-08-30",
    "Total_Tasks__c": 4,
    "Completed_Tasks__c": 1
  }
]
```

### 1.2 Get Single Customer Details
* **URL**: `/onboarding/customers/{id}`
* **Method**: `GET`
* **Response**: `200 OK` (Success) or `404 Not Found` (Record does not exist)
* **Response Body (200)**:
```json
{
  "Id": "a00fj00000X1234EAB",
  "Name": "Apex Corp",
  "Company__c": "Apex Enterprises",
  "Email__c": "info@apex.com",
  "Phone__c": "+1 (555) 123-4567",
  "Industry__c": "Technology",
  "Customer_Type__c": "Enterprise",
  "Onboarding_Status__c": "New Customer",
  "Go_Live_Date__c": "2026-08-30",
  "Total_Tasks__c": 4,
  "Completed_Tasks__c": 1
}
```

### 1.3 Create Customer
* **URL**: `/onboarding/customers`
* **Method**: `POST`
* **Request Body**:
```json
{
  "Name": "Apex Corp",
  "Company__c": "Apex Enterprises",
  "Email__c": "info@apex.com",
  "Phone__c": "1234567890",
  "Industry__c": "Technology",
  "Customer_Type__c": "Enterprise",
  "Go_Live_Date__c": "2026-10-01"
}
```
* **Response**: `201 Created` on success, `400 Bad Request` on failure (e.g. missing fields, past go-live date).
* **Response Body (201)**:
```json
{
  "Id": "a00fj00000X1234EAB",
  "Name": "Apex Corp",
  "Company__c": "Apex Enterprises",
  "Email__c": "info@apex.com",
  "Phone__c": "1234567890",
  "Industry__c": "Technology",
  "Customer_Type__c": "Enterprise",
  "Onboarding_Status__c": "New Customer",
  "Go_Live_Date__c": "2026-10-01",
  "Total_Tasks__c": 0,
  "Completed_Tasks__c": 0
}
```

### 1.4 Update Customer Fields
* **URL**: `/onboarding/customers/{id}`
* **Method**: `PATCH`
* **Request Body**:
```json
{
  "Company__c": "Apex International",
  "Phone__c": "9876543210"
}
```
* **Response**: `200 OK` on success, `400 Bad Request` or `404 Not Found` on failure.

### 1.5 Update Onboarding Status (Transition Stage)
Executes the stage transition logic and automatically inserts an audit note detailing the reason/action of the change.
* **URL**: `/onboarding/customers/{id}/status`
* **Method**: `PATCH`
* **Request Body**:
```json
{
  "status": "Implementation",
  "note": "Initial requirements meeting complete. Transitioning to implementation team."
}
```
* **Response**: `200 OK` on success, `400 Bad Request` or `404 Not Found` on failure.
* **Response Body (200)**:
```json
{
  "Id": "a00fj00000X1234EAB",
  "Name": "Apex Corp",
  "Onboarding_Status__c": "Implementation",
  "Go_Live_Date__c": "2026-10-01",
  "Total_Tasks__c": 0,
  "Completed_Tasks__c": 0
}
```

---

## 2. Task Endpoints

### 2.1 Create Onboarding Task
* **URL**: `/onboarding/tasks`
* **Method**: `POST`
* **Request Body**:
```json
{
  "Name": "Setup Cloud Integration",
  "Customer__c": "a00fj00000X1234EAB",
  "Due_Date__c": "2026-07-25",
  "Status__c": "Pending",
  "Description__c": "Configure client credentials in Sandbox."
}
```
* **Response**: `201 Created` on success, `400 Bad Request` on validation failure.

### 2.2 Update Onboarding Task (Status Toggle or Fields)
* **URL**: `/onboarding/tasks/{id}`
* **Method**: `PATCH`
* **Request Body**:
```json
{
  "Status__c": "Completed"
}
```
* **Response**: `200 OK` on success, `400 Bad Request` or `404 Not Found` on failure.
