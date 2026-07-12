# Setup and Deployment Instructions

This document provides step-by-step instructions on deploying the Customer Onboarding Tool, running unit tests, assigning permissions, and configuring the Lightning interface.

---

## 1. Prerequisites
- **Salesforce CLI**: Ensure the Salesforce CLI (`sf`) is installed and configured on your machine.
- **Authorized Org**: Ensure you are logged into your target org and it is set as your default org.
  - To verify current org: `sf org display`
  - To log in: `sf org login web`

---

## 2. Deploy Metadata to Salesforce Org

To deploy all files (custom objects, fields, layout, Apex triggers, Apex classes, and LWCs) in the Salesforce DX structure, run:
```bash
sf project deploy start --source-dir force-app
```

*Note: If there are metadata discrepancies in the org, you can clean up the org schema by executing the destructive changes manifest:*
```bash
sf project deploy start --manifest manifest/package.xml --post-destructive-changes manifest/destructiveChanges.xml
```

---

## 3. Assign Permission Set

The schema requires strict Field-Level Security. To access custom objects and custom fields on `Customer__c` and `Onboarding_Task__c`, assign the permission set to yourself:
```bash
sf org assign permset --name Customer_Onboarding_User
```

---

## 4. Run Unit Tests

To execute all local tests and verify Apex correctness and code coverage, run the test suite:
```bash
sf apex run test --test-level RunLocalTests --wait 10
```
This runs 33 unit tests checking all services, controllers, triggers, and REST endpoints under a permitted Standard User context.

---

## 5. Configure the Lightning Web App Component

To display the single-page application onboarding tool in the Salesforce interface, complete the following steps:

1. Log in to your Salesforce Org via browser:
   ```bash
   sf org open
   ```
2. Navigate to **Setup** (gear icon top right) and search for **Lightning App Builder** in the Quick Find box.
3. Click **New** to create a new Lightning Page:
   - Select **App Page**.
   - Set the label to **Customer Onboarding Portal**.
   - Select **One Region** or **Main Region and Sidebar** layout (the component is responsive).
4. On the left side panel, find the custom LWC component under the name: **Customer Onboarding Portal (Shell)** (this matches the `onboardingApp` component).
5. Drag and drop **Customer Onboarding Portal (Shell)** onto the page region canvas.
6. Click **Save** in the top right.
7. Click **Activate**:
   - In the activation settings, add the page to your target application (e.g. standard Sales or Service app navigation menu).
   - Set it visible to System Administrator and Standard User profiles.
8. Click **Save** and exit.
9. Open the App Launcher (grid icon top left), search for your app or **Customer Onboarding Portal**, and open it. You will see the portal dashboard, search list, detail view, and task tracking running.
