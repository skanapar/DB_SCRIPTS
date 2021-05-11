set long 4000
set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a60
col sid format 999
col ocategory format a10
col EXECUTIONS_TOTAL format 99999 heading Execs
col "Elapsed secs" format 99999999
col begin_interval_time format a30


 select 
 s.begin_interval_time, s.snap_id, 
q.plan_hash_value,
q.loaded_versions,
q.version_count,
q.PX_SERVERS_EXECS_TOTAL,
q.sql_profile,
q.MODULE, q.PARSING_SCHEMA_NAME, 
 q.EXECUTIONS_TOTAL, q.DISK_READS_TOTAL, q.ROWS_PROCESSED_TOTAL, q.ELAPSED_TIME_TOTAL/1000000 "Elapsed secs"
 from dba_hist_sqlstat q, dba_hist_snapshot s
 where q.snap_id = s.snap_id
 and s.begin_interval_time > to_date('&begin_time','YYMMDD HH24:MI')
 and sql_id='&sqlid'
 order by s.begin_interval_time
 /
