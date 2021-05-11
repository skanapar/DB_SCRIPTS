set lines 132
set verify off
col sample_time for a35
col sql_id for a14
col child for 99999
col file_block for a15
col blocking for a10
col seconds_waited for 999,999.99
col avg_waited for 999,999.99
compute sum of times_waited seconds_waited on report
break on report
accept since_when -
       prompt 'Enter Earliest Event Date: ' -
       default sysdate-1
select
-- sample_time, instance_number,
sql_id, 
sql_child_number child,
event,
count(*) times_waited,
sum(time_waited/1000000) seconds_waited,
(sum(time_waited/1000000))/count(*) avg_waited
-- blocking_session||'.'||blocking_session_serial# blocking,
-- current_file#||'.'||current_block# file_block,
-- program, module, action, client_id,
from dba_hist_active_sess_history
where event like nvl('&event',event)
-- and sample_time between '03-may-06 10.00.00.000 AM'
-- and '03-MAY-06 11.00.00.000 AM'
and sample_time > &&since_when
and blocking_session is not null
group by
sql_id, sql_child_number, event
order by 4
/
undef since_when
