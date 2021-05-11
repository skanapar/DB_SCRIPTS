set lines 155
col etime for 999,999.999
col lio for 999,999,999.9
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select ss.snap_id, ss.instance_number node, begin_interval_time, sql_id, plan_hash_value,
(elapsed_time_delta/decode(nvl(executions_delta,0),0,1,executions_delta))/1000000 etime,
(buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta)) lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where sql_id = nvl('&sql_id','4dqs2k5tynk61')
and ss.snap_id = S.snap_id
and executions_delta > 0
order by 1, 2, 3
/
