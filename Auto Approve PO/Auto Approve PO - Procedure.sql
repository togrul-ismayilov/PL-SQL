CREATE OR REPLACE PROCEDURE UYUMSOFT.approve_po (
    P_approval_transactions_id   IN GNLT_APPROVAL_TRANSACTION.APPROVAL_TRANSACTIONS_ID%TYPE,
    P_approval_role_m_id         IN GNLT_APPROVAL_TRANSACTION.APPROVAL_ROLE_M_ID%TYPE,
    P_ROUTE_NUMBER               IN GNLT_APPROVAL_TRANSACTION.ROUTE_NUMBER%TYPE)
AS
    V_APPROVAL_ROUTES_M_ID       GNLT_APPROVAL_TRANSACTION.APPROVAL_ROUTES_M_ID%TYPE;
    V_next_approval_role_m_id    GNLT_APPROVAL_TRANSACTION.APPROVAL_ROLE_M_ID%TYPE;
    V_approval_rules_m_id        GNLT_APPROVAL_TRANSACTION.approval_rules_m_id%TYPE;
    v_co_id                      GNLT_APPROVAL_TRANSACTION.CO_ID%TYPE;
    V_BRANCH_ID                  GNLT_APPROVAL_TRANSACTION.BRANCH_ID%TYPE;
    v_source_m_id                GNLT_APPROVAL_TRANSACTION.source_m_id%TYPE;
    v_source_d_id                GNLT_APPROVAL_TRANSACTION.source_d_id%TYPE;
    V_NEXT_ROUTE_NUMBER          GNLT_APPROVAL_TRANSACTION.ROUTE_NUMBER%TYPE;
    v_message_text               GNLT_APPROVAL_TRANSACTION.MESSAGE_TEXT%TYPE;
    v_IS_UPDATE_APPROVAL_VALUE   GNLT_APPROVAL_TRANSACTION.IS_UPDATE_APPROVAL_VALUE%TYPE;
    V_IS_PROCESSED               GNLT_APPROVAL_TRANSACTION.IS_PROCESSED%TYPE;
    
BEGIN
    BEGIN
        -- Get the approval route ID for the PO
        SELECT APPROVAL_ROUTES_M_ID,
               approval_rules_m_id,
               co_id,
               BRANCH_ID,
               source_m_id,
               source_d_id,
               MESSAGE_TEXT
          INTO V_APPROVAL_ROUTES_M_ID,
               V_approval_rules_m_id,
               v_co_id,
               V_BRANCH_ID,
               v_source_m_id,
               v_source_d_id,
               v_message_text
          FROM GNLT_APPROVAL_TRANSACTION
         WHERE     approval_transactions_id = P_approval_transactions_id
               AND approval_role_m_id = P_approval_role_m_id
               AND APPROVAL_STATUS = 3
               AND APPROVAL_FORMS_ID = 87
               AND CO_ID = 2374;



          -- Get the next approver in the approval route
          SELECT APPROVAL_ROLE_M_ID, ROUTE_NUMBER
            INTO V_next_approval_role_m_id, V_NEXT_ROUTE_NUMBER
            FROM GNLD_APPROVAL_ROUTES
           WHERE     APPROVAL_ROUTES_M_ID = V_APPROVAL_ROUTES_M_ID
                 AND ROUTE_NUMBER > P_ROUTE_NUMBER
                 AND APPROVAL_RULES_M_ID IN (SELECT APPROVAL_RULES_M_ID
                                               FROM GNLD_APPROVAL_RULES_M
                                              WHERE CO_ID = 2374)
        ORDER BY ROUTE_NUMBER ASC
           FETCH FIRST 1 ROW ONLY;
    -- When the role is the last one in the route
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
            V_next_approval_role_m_id := NULL;
            V_NEXT_ROUTE_NUMBER := NULL;
          
    END;


    -- Update the current approval transaction with the approver ID and approval date
    UPDATE GNLT_APPROVAL_TRANSACTION
       SET APPROVAL_STATUS = 1,
           update_user_id = 111,
           update_date = SYSDATE,
           APPROVAL_DATE = SYSDATE,
            NOTE_LARGE = 'Auto Approved'
     WHERE approval_transactions_id = P_approval_transactions_id;


    -- Insert a new approval transaction for the next approver in the route
    IF V_next_approval_role_m_id IS NOT NULL
    THEN
        INSERT INTO GNLT_APPROVAL_TRANSACTION (
               SOURCE_M_ID,
               source_d_id,
               APPROVAL_FORMS_ID,
               ROUTE_NUMBER,
               CO_ID,
               BRANCH_ID,
               approval_rules_m_id,
               APPROVAL_ROLE_M_ID,
               APPROVAL_STATUS,
               APPROVAL_ROUTES_M_ID,
               create_user_id,
               create_date,
               APPROVAL_CREATE_DATE,
               estimated_approval_date,
               update_user_id,
               user_id,
               update_date,
               approval_date,
               MESSAGE_TEXT,
               IS_UPDATE_APPROVAL_VALUE,
               --NOTE_LARGE,
               APPROVAL_STATUS_ID,
               IS_PROCESSED)
        VALUES (
                V_SOURCE_M_ID,
                v_source_d_id,
                87,
                V_NEXT_ROUTE_NUMBER,
                v_co_id,
                V_BRANCH_ID,
                V_approval_rules_m_id,
                V_next_approval_role_m_id,
                3,
                V_APPROVAL_ROUTES_M_ID,
                111,
                SYSDATE,
                SYSDATE,
                SYSDATE,
                0,
                0,
                TO_DATE ('01.01.0001', 'DD.MM.YYYY'),
                TO_DATE ('01.01.0001', 'DD.MM.YYYY'),
                v_message_text,
                v_IS_UPDATE_APPROVAL_VALUE,
               -- 'Auto Created',
                14,
                V_IS_PROCESSED);
        
        -- Update order status as "Onay Yolunda"
        UPDATE PSMT_ORDER_D
            SET REQUEST_STATUS = 2     
            WHERE order_m_id = v_source_m_id;

        UPDATE PSMT_ORDER_M
            SET REQUEST_STATUS = 2
            WHERE order_m_id = v_source_m_id;
    ELSE
    
        -- Update order status as "Onaylandi"
        UPDATE PSMT_ORDER_D
           SET REQUEST_STATUS = 4       
         WHERE order_m_id = v_source_m_id;

        UPDATE PSMT_ORDER_M
           SET REQUEST_STATUS = 4
         WHERE order_m_id = v_source_m_id;
    END IF;

    COMMIT;
END;
/