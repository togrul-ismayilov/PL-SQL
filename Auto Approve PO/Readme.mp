# Automated Purchase Order Approval Job

This Oracle Database code snippet represents an automated job designed to streamline the approval process for purchase orders (POs) within an organization. The code utilizes PL/SQL to interact with the Oracle Database. The objective of this job is to automatically approve purchase orders that meet specific criteria, optimizing the approval workflow and reducing manual intervention.

## Overview:

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

## Purpose and Benefits:

This automated job significantly enhances the efficiency of the purchase order approval process by intelligently identifying and approving eligible transactions. By leveraging a calendar table to calculate working days and applying specific criteria, the job ensures that only relevant transactions are processed. The automation reduces the need for manual intervention and expedites the approval of low-value purchase orders, optimizing resource allocation and improving overall operational productivity.
