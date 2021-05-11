--prompt enter file name for output

SET linesize 32767
SET WRAP OFF
set arraysize 1000
SET TRIMSPOOL ON
SET term on


--PROMPT min/max sample time and sample count
--PROMPT 

SELECT min(sample_time), max(sample_time), count(*)
FROM TABLE(GV$(CURSOR(
SELECT a.sample_time
FROM v$active_session_history a
)))
/

--PROMPT 
--PROMPT min/max sample time, sample count and sql id not null
--PROMPT 

SELECT min(sample_time), max(sample_time), count(*)
FROM TABLE(GV$(CURSOR(
SELECT a.sample_time
FROM v$active_session_history a
where a.sql_id IS NOT NULL
)))
/
--PROMPT 
--PROMPT min/max sample time, sample count, sql id/exec id not null and session cpu and non-idle 
--PROMPT 

SELECT min(sample_time), max(sample_time), count(*)
FROM TABLE(GV$(CURSOR(
SELECT sample_time
FROM v$active_session_history a
where a.sql_id IS NOT NULL
AND a.sql_exec_id IS NOT NULL
AND a.sql_exec_start IS NOT NULL
AND (a.session_state = 'ON CPU' OR a.wait_class <> 'Idle')
)))
/
--PROMPT 
--PROMPT min/max sample time, sample count, sql id/exec id not null and session cpu and non-idle and module filter
--PROMPT 

SELECT min(sample_time), max(sample_time), count(*)
FROM TABLE(GV$(CURSOR(
SELECT sample_time
FROM v$active_session_history a
where a.sql_id IS NOT NULL
AND a.sql_exec_id IS NOT NULL
AND a.sql_exec_start IS NOT NULL
AND (a.session_state = 'ON CPU' OR a.wait_class <> 'Idle')
AND a.module not in ('omc_dbperf_currentomc_oracle_db', 'omc_dbperf_AWRomc_oracle_db', 'emagent_SQL_omc_oracle_db', 'omc_sqlperf_ASHomc_oracle_db')
)))
/
--PROMPT 
--PROMPT ASH Info
--PROMPT 


select * from v$ash_info
/
--spool off

