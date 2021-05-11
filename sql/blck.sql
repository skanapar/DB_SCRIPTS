set ine 150
column sess_detail format a120
column blocker format a15
select rpad(rpad('+',level,'-'),8,' ') || lpad(sid||','||serial#,8,' ') || ' ' || sess.module ||' '||sess.sql_id||' '||sess.status||' '||wait_event_text sess_detail,
   blocker_sid||','||blocker_sess_serial# blocker
from v$wait_chains c
     left outer join dba_objects o on (row_wait_obj# = object_id)
     join v$session sess using (sid)
     left outer join v$sql sql on (sql.sql_id = sess.sql_id and sql.child_number = sess.sql_child_number)
connect by prior sid = blocker_sid
    and prior sess_serial# = blocker_sess_serial#
    and prior instance = blocker_instance
start with blocker_is_valid = 'FALSE'
/
