BEGIN
                     FOR po IN ( WITH WORK_DAYS AS (SELECT WD.*, ROWNUM R FROM (SELECT CALENDAR_DATE CD FROM GNLD_CALENDAR 
                                        WHERE CALENDAR_TYPE_ID = 46
                                            AND CALENDAR_DAY_TYPE = 3
                                            AND CALENDAR_DATE <= trunc(SYSDATE)
                                            ORDER BY CALENDAR_DATE DESC
                                             )WD )
SELECT GAT.approval_transactions_id, GAT.approval_role_m_id, GAT.ROUTE_NUMBER, GAT.SOURCE_M_ID, GAT.create_date
                                FROM GNLT_APPROVAL_TRANSACTION GAT
                                INNER JOIN PSMT_ORDER_M POM ON POM.ORDER_M_ID=GAT.SOURCE_M_ID
                                WHERE GAT.APPROVAL_FORMS_ID=87
                                 AND GAT.APPROVAL_STATUS = 3
                                 AND GAT.CO_ID =2374
                                 AND POM.AMT_RECEIPT< 10000
                                 AND  GAT.create_date < (
                                   SELECT CD FROM WORK_DAYS
                                   WHERE R=3
                                ))
                     LOOP
                       approve_po(po.approval_transactions_id, po.approval_role_m_id, po.ROUTE_NUMBER);
                     END LOOP;
                   END;
                   
                   