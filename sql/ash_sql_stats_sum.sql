break on plan_hash_value 
col execs for 999,999,999
col avg_etime for 999.999
col avg_pio for 999,999.9
col avg_lio for 999,999.9
col avg_iowait for 999.999
select 
sum(executions_delta) execs, 
-- elapsed_time_delta etime, 
sum((elapsed_time_delta/10000000)/executions_delta) avg_etime, 
-- disk_reads_delta pio, 
sum(disk_reads_delta/executions_delta) avg_pio, 
sum((iowait_delta/10000000)/executions_delta) avg_iowait,
sum(buffer_gets_delta/executions_delta) avg_lio,
plan_hash_value
from DBA_HIST_SQLSTAT
where sql_id like nvl('&sql_id','3vsqrwtut51h7')
group by plan_hash_value
order by min(snap_id)
/
