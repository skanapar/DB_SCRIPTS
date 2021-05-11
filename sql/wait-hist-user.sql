select a.snap_id, s.BEGIN_INTERVAL_TIME, a.sql_id, a.EVENT, sum(a.WAIT_TIME)
from dba_hist_active_sess_history a, dba_hist_snapshot s
where a.user_id = (select user_id from dba_users where username=upper('&user_name'))
and a.snap_id = s.snap_id
and s.BEGIN_INTERVAL_TIME > sysdate-&days_back
group by a.snap_id, s.BEGIN_INTERVAL_TIME, a.sql_id, a.EVENT
having sum(a.WAIT_TIME)>0
/
