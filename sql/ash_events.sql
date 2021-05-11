set pages 9999
set verify off
select sql_id, event, p1text,p1,p2text,p2,p3text,p3,wait_time, time_waited, program, module
from dba_hist_active_sess_history
where event like nvl('&event',event)
and rownum < nvl('&how_many',20 )
/
