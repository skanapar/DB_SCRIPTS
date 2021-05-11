/* Formatted on 01-Mar-2018 17:02:51 (QP5 v5.309) */
SELECT target_name,
       target_guid,
       target_type,
       availability_status,
       total_days_in_state,
       ROUND (
           ratio_to_report (total_days_in_state)
               OVER (PARTITION BY target_guid),
           2)*100
           AS percentage
FROM (SELECT target_name,
             target_guid,
             target_type,
             availability_status,
             SUM (days_in_state) total_days_in_state
      FROM (SELECT target_name,
                   target_guid,
                   a.target_type,
                   availability_status,
                   ROUND (
                         NVL (
                             CASE
                                 WHEN end_timestamp >=
                                      TO_DATE ('31-Jan-18 23:59:59',
                                               'DD-MON-RR HH24:MI:SS')
                                 THEN
                                     TO_DATE ('31-Jan-18 23:59:59',
                                              'DD-MON-RR HH24:MI:SS')
                                 WHEN end_timestamp <
                                      TO_DATE ('31-Jan-18 23:59:59',
                                               'DD-MON-RR HH24:MI:SS')
                                 THEN
                                     end_timestamp
                                 ELSE
                                     end_timestamp
                             END,
                             TO_DATE ('31-Jan-18 23:59:59',
                                      'DD-MON-RR HH24:MI:SS'))
                       - CASE
                             WHEN start_timestamp <=
                                  TO_DATE ('01-Jan-18', 'DD-MON-RR')
                             THEN
                                 TO_DATE ('01-Jan-18', 'DD-MON-RR')
                             WHEN start_timestamp >
                                  TO_DATE ('31-Jan-18 23:59:59',
                                           'DD-MON-RR HH24:MI:SS')
                             THEN
                                 TO_DATE ('31-Jan-18 23:59:59',
                                          'DD-MON-RR HH24:MI:SS')
                             ELSE
                                 start_timestamp
                         END,
                       2)
                       days_in_state
            FROM sysman.mgmt$availability_history a
            WHERE     (    a.start_timestamp <=
                           TO_DATE ('31-Jan-18 23:59:59',
                                    'DD-MON-RR HH24:MI:SS')
                       AND NVL (end_timestamp, SYSDATE) >=
                           TO_DATE ('01-Jan-18', 'DD-MON-RR'))
                  --AND target_name = 'qaaacgovmid01.us.pioneernrc.pvt'
                  ) b
      GROUP BY target_name,
               target_guid,
               target_type,
               availability_status)