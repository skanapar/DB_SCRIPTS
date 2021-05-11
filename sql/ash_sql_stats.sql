break on plan_hash_value 
col avg_etime for 999.999
col avg_pio for 999,999.9
col avg_iowait for 999.999
select 
-- executions_delta execs, 
-- elapsed_time_delta etime, 
(elapsed_time_delta/1000000)/executions_delta avg_etime, 
-- disk_reads_delta pio, 
disk_reads_delta/executions_delta avg_pio, 
(iowait_delta/1000000)/executions_delta avg_iowait,
plan_hash_value
from DBA_HIST_SQLSTAT
where sql_id like nvl('&sql_id','3vsqrwtut51h7')
order by snap_id
/
