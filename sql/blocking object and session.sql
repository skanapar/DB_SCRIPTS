SELECT s1.username blocking_user
                    ,s1.machine blocking_machine
                    ,s1.sid blocking_sid
                    ,s2.username blocked_user
                    ,s2.machine blocked_machine
                    ,s2.sid blocked_sid
                    ,obj1.object_name
                    ,obj1.row_wait_obj#
                    ,obj1.row_wait_file#
                    ,obj1.row_wait_block#
                    ,obj1.row_wait_row#
                    ,obj1.row_id
                    ,l2.ctime l2ctime
                FROM v$lock l1
                    ,v$session s1
                    ,v$lock l2
                    ,v$session s2
                    ,(SELECT s.sid
                            ,do.owner || '.' || do.object_name object_name
                            ,row_wait_obj#
                            ,row_wait_file#
                            ,row_wait_block#
                            ,row_wait_row#
                            ,DBMS_ROWID.rowid_create(1
                                                    ,row_wait_obj#
                                                    ,row_wait_file#
                                                    ,row_wait_block#
                                                    ,row_wait_row#)
                                 row_id
                        FROM v$session s, dba_objects do
                       WHERE s.row_wait_obj# = do.object_id) obj1
               WHERE     s1.sid = l1.sid
                     AND s2.sid = l2.sid
                     AND l1.block = 1
                     AND l2.request > 0
                     AND l1.id1 = l2.id1
                     AND l2.id2 = l2.id2
                     AND obj1.sid(+) = s2.sid
            ORDER BY s1.sid, s2.sid;