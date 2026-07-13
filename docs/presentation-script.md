# Presentation Script: Customer Onboarding Portal

Use this script to guide your screen-recording and voiceover for your final project submission. 

**Recommended Video Length**: 5 to 7 Minutes
**Required Setup**: 
- Web Browser open to your **Customer Onboarding Portal** page in Salesforce.
- VS Code open to the project workspace.
- GitHub open to your repository page (`sarvesh0506/customer-onboarding-tool`).

---

## 🎬 Section 1: Introduction (Duration: ~45 seconds)

*   **Visual**: Screen showing the **Customer Onboarding Portal** inside Salesforce, fully populated with the 50 sample customer records. Make sure the dashboard is visible at the top. Move your cursor slightly over the KPI cards.
*   **Voiceover**:
    > "Hello, my name is Sarveshkumar, and today I am excited to demonstrate my implementation of the **Customer Onboarding Portal** built on Salesforce. 
    > 
    > When a sales cycle concludes, transitioning a client successfully to implementation and go-live is critical. This portal is a single-page application built using Lightning Web Components (LWC), Apex Services, and REST web resources. It coordinates customer stages, tracks onboarding checklists, uploads setup documents, and logs audit note histories—all in a secure, responsive, and visual interface."

---

## 🖥️ Section 2: Portal Live Demo (Duration: ~2 minutes)

*   **Visual**: Scroll through the top **KPI metrics** and point to the **Customers by Onboarding Stage** bar chart.
*   **Voiceover**:
    > "Starting with the dashboard at the top of the portal, we have real-time KPI metrics. Here we see our **Total Onboarding Customers**, **Overdue Tasks**, and the **Ready for Go-Live** pipeline—which dynamically calculates customers in the UAT stage with a go-live target in the next 7 days.
    >
    > Below that, a horizontal stage chart displays the distribution of our 50 active onboarding customers."

*   **Visual**: Move to the left sidebar **Customers** listing. Type *'Stark'* in the search box, showing it filter down. Then, clear the search and change the **Filter by Stage** combobox to *'UAT'*.
*   **Voiceover**:
    > "On the left is the customer navigation sidebar. It features a debounced search input allowing users to search across names, companies, and emails. We can also filter lists dynamically by stage, such as showing only customers in UAT."

*   **Visual**: Clear filters and click on **Stark Industries** (or any customer in UAT stage). The right details panel loads. Point out the **details grid** and the **Progress Step Path** at the top.
*   **Voiceover**:
    > "Clicking a customer instantly loads their workspace on the right. At the top of details, we see a custom progress step path showing completed milestones in green checkmarks, the active stage in blue, and future stages. Below that is our customer field details grid showing email, phone, owner, and plan dates."

*   **Visual**: Click on the **Edit Details** button in the details header. Modify the phone number or industry in the modal, and click **Save Details**. Show the success toast and details reload.
*   **Voiceover**:
    > "To edit customer fields directly within the portal, I can click **Edit Details**. This opens an inline modal containing standard-validated inputs. Once saved, it refreshes the details card, sidebar, and dashboard in real-time."

*   **Visual**: Select a customer in the **Documentation Pending** stage (e.g. *Wayne Enterprises* or *LexCorp*). Point out the **Onboarding Documentation Upload** box.
*   **Voiceover**:
    > "As a bonus feature, the portal dynamically mounts a **File Uploader** only when a customer is in the 'Documentation Pending' stage. This lets coordinators drag and drop contracts, setup specifications, and SLAs directly onto the record."

*   **Visual**: Scroll down to the **Tasks Management** section. Hover over the red **OVERDUE** badge. Click the checkbox next to a task to toggle its completion, and show the progress circle update from 0% to 50%/100%. Then click **Add Task**, fill out the task name/due date in the modal, and click save.
*   **Voiceover**:
    > "In the Task Management pane, we manage onboarding checklists. Overdue tasks are automatically flagged with a red, pulsing warning badge. 
    >
    > We can check off tasks inline. Toggling a task updates the database and dynamically updates our onboarding progress percentage. We can also click **Add Task** to create new checklists inline with validation controls."

*   **Visual**: Click the **Update Stage** button on details. Select a customer that has open tasks (e.g., *Initech Solutions*), choose **Go Live** or **Completed**, and click **Save Changes**. Show the red validation toast: *"Error Saving Changes: Still tasks are yet to complete..."*.
*   **Voiceover**:
    > "To enforce data quality, we built a custom business validation rule. If a user attempts to transition a customer to 'Go Live' or 'Completed' while they still have pending or overdue tasks, the backend blocks the update and displays a red alert toast, prompting the coordinator to clear the checklists first."

*   **Visual**: Check off the remaining open tasks for that customer in the checklist so it reaches 100% completion. Open **Update Stage** again, select **Go Live**, enter a note, and save. The path updates to green/blue successfully.
*   **Voiceover**:
    > "Once all tasks are marked as completed, the validator passes. We can now successfully transition the customer to Go Live or Completed, which logs a permanent history entry in the database and triggers email alerts to the account owner."

---

## ⚙️ Section 3: Under the Hood & Code Tour (Duration: ~2 minutes)

*   **Visual**: Switch to **VS Code**. Show the **Data Model** folders in `force-app/main/default/objects/`. Open `Customer__c.object-meta.xml`.
*   **Voiceover**:
    > "Now let's look under the hood. The database is built around three custom objects: `Customer__c`, `Onboarding_Task__c`, and `Onboarding_Note__c`, connected via Master-Detail relationships.
    >
    > This design ensures that if a customer is deleted, all their related checklists and audit history are automatically deleted to maintain data integrity."

*   **Visual**: Open [CustomerService.cls](file:///force-app/main/default/classes/CustomerService.cls). Point out the `updateOnboardingStatus` method and the stage validation check query.
*   **Voiceover**:
    > "I've structured the backend using a strict multi-tier architecture. Business logic resides in `*Service` classes like `CustomerService` and `TaskService`. 
    > 
    > In `CustomerService.updateOnboardingStatus`, we check for incomplete tasks using a fast aggregate query. To pass Salesforce security standards, all SOQL queries use the `WITH SECURITY_ENFORCED` clause, and DML operations utilize `Security.stripInaccessible` to enforce Field-Level Security and CRUD checks."

*   **Visual**: Open [OnboardingTriggerHandler.cls](file:///force-app/main/default/classes/OnboardingTriggerHandler.cls). Show the email bulkification logic.
*   **Voiceover**:
    > "Here is our trigger handler logic. When a customer's stage changes, the trigger automatically fires email notifications to the Account Owner. This handler is fully bulkified, compiling alerts in a single call to stay within governor limits."

*   **Visual**: Open [CustomerRestResource.cls](file:///force-app/main/default/classes/CustomerRestResource.cls). Point out `@RestResource` mapping and exception handlers.
*   **Voiceover**:
    > "For third-party integrations, I exposed robust REST endpoints at `/onboarding/customers/*` and `/onboarding/tasks/*`. The REST layer maps HTTP methods to services and translates Apex exceptions into standard HTTP codes like 200, 201, 400, and 404."

---

## 🛠️ Section 4: Repository & Testing (Duration: ~1 minute)

*   **Visual**: Switch to **GitHub** and show the repository main page, pointing to the **Master README.md** and the **`docs/`** directory.
*   **Voiceover**:
    > "The repository follows standard Salesforce DX guidelines. The root directory contains a complete **README.md** detailing system architecture diagrams, database schemas, REST payloads, and CLI setup instructions. The **`docs`** folder contains separate deep-dive guides for evaluation."

*   **Visual**: Show the terminal output in VS Code where the tests ran successfully. Point to the **100% Pass** and **87% Coverage** lines.
*   **Voiceover**:
    > "To verify correctness, I wrote a test suite of 37 unit tests checking all services, controllers, triggers, and REST resources. 
    > 
    > The tests compile and execute under standard-user security contexts, achieving a **100% pass rate** and **87% org-wide code coverage**, exceeding the 85% project target."

---

## 👋 Section 5: Conclusion (Duration: ~20 seconds)

*   **Visual**: Switch back to the **Salesforce Portal** in Chrome, showing the customer workspace page.
*   **Voiceover**:
    > "In conclusion, this project combines robust security, clean architectural separation, bulkified automation, and a modern, responsive user experience. Thank you for watching my demo!"
