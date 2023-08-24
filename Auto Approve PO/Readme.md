# Automated Purchase Order Approval Project

This Oracle Database code snippet represents an automated job designed to streamline the approval process for purchase orders (POs) within an organization. The code utilizes PL/SQL to interact with the Oracle Database. The objective of this project is to automatically approve purchase orders that meet specific criteria, optimizing the approval workflow and reducing manual intervention.

##  Job Overview:

The code works as follows:

- **Working Day Calculation:**
  - The code relies on the `GNLD_CALENDAR` table to calculate working days, excluding weekends and holidays.
  - It selects dates marked as working days (`CALENDAR_DAY_TYPE = 3`) and orders them in descending order, considering only dates up to the current date.

- **Main Query and Conditions:**
  - The primary query retrieves relevant data from the `GNLT_APPROVAL_TRANSACTION` and `PSMT_ORDER_M` tables.
  - It selects critical columns associated with approval transactions, such as `approval_transactions_id`, `approval_role_m_id`, `ROUTE_NUMBER`, `SOURCE_M_ID`, and `create_date`.
  - Conditions are applied to filter the results:
    - The approval form must have an ID of 87 which signifies a purchase order.
    - The approval status must indicate that the approval is pending (`APPROVAL_STATUS = 3`).
    - The company ID must match 2374.
    - The invoice amount (`AMT_RECEIPT`) in the `PSMT_ORDER_M` table must be less than 10000.
    - The creation date (`create_date`) of the transaction must be earlier than a predetermined threshold date obtained from the working day calculation.

- **Loop and Approval:**
  - The retrieved approval transactions meeting the specified conditions are processed in a loop.
  - For each transaction, the `approve_po()` procedure is invoked, passing the relevant parameters:
    - `approval_transactions_id`: ID of the approval transaction.
    - `approval_role_m_id`: ID of the approval role.
    - `ROUTE_NUMBER`: Route number associated with the transaction.


### Purpose of Job:

This automated job significantly enhances the efficiency of the purchase order approval process by intelligently identifying and approving eligible transactions. By leveraging a calendar table to calculate working days and applying specific criteria, the job ensures that only relevant transactions are processed. The automation reduces the need for manual intervention and expedites the approval of low-value purchase orders, optimizing resource allocation and improving overall operational productivity.


## Procedure Overview:

1. **Input Parameters:**
   - `P_approval_transactions_id`: The ID of the approval transaction.
   - `P_approval_role_m_id`: The ID of the current approval role.
   - `P_ROUTE_NUMBER`: The current route number in the approval process.

2. **Fetching Approval Route:**
   - The procedure first retrieves key information related to the approval transaction:
     - `APPROVAL_ROUTES_M_ID`: The ID of the approval route associated with the PO.
     - `approval_rules_m_id`: The ID of the approval rule.
     - `co_id`: The company ID.
     - `BRANCH_ID`: The branch ID.
     - `source_m_id`: The ID of the source (PO).
     - `source_d_id`: The ID of the source detail.
     - `MESSAGE_TEXT`: Message associated with the approval.

3. **Finding Next Approver:**
   - It then searches for the next approver in the approval route based on route number and specific conditions.
   - If no next approver is found, it signifies that the current approver is the last one.

4. **Updating Current Transaction:**
   - The procedure updates the current approval transaction with various details:
     - Sets the `APPROVAL_STATUS` to 1 (approved).
     - Assigns an `update_user_id`.
     - Updates `update_date`, `APPROVAL_DATE`, and other fields.
     - Adds a note indicating automated approval.

5. **Inserting New Approval Transaction:**
   - If a next approver exists, a new approval transaction is inserted for them.
   - The procedure prepares the necessary data and inserts it into `GNLT_APPROVAL_TRANSACTION`.
   - The status is set to "Pending" (status code 3), and other relevant fields are populated.
   - The `PSMT_ORDER_D` and `PSMT_ORDER_M` tables are updated with the new status.

6. **Updating Order Status:**
   - If there's no next approver (last approver), the procedure updates the order status to "Approved" in the `PSMT_ORDER_D` and `PSMT_ORDER_M` tables.

### Purpose of Procedure:

This procedure forms a crucial part of the organization's automated approval process for purchase orders. By orchestrating the approval route, updating transaction statuses, and managing transitions between approvers, it significantly reduces the need for manual intervention in the approval workflow. 
