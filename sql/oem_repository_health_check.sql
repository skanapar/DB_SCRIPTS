REM Copyright (C) Think Forward.com 1998- 2005. All rights reserved. 
set linesize 130
set pagesize 50000
Set feedback off
set heading off

SPOOL em10g_health.log

PROMPT ********* Report to capture the Health of the EM Grid Control Repository  ******

Prompt
Prompt ***   EM Vital Statistics   ***
Prompt --------------------------------

--- Total number of targets monitored by EM
select 'Total Targets=', TO_CHAR(count(*)) from mgmt_targets;

--- Number of targets that are not listed with an 'UP' availability status.
select 'Targets Not Up=',to_char(count(*)) from mgmt_current_availability where current_status != 1;

--- Loader Thread count
select  'Loader Threads=', TO_CHAR(count(distinct key_value))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Management_Loader_Status' and
m.metric_column = 'load_processing' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ');

--- Rows per second per loader thread.
select 'Avg Loader Rows/Second/Thread=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Management_Loader_Status' and
m.metric_column = 'load_processing' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;
 
--- Loader rows per hour
select 'Avg Loader Rows/Hour/Thread=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Management_Loader_Status' and
m.metric_column = 'loader_processing_hour' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;
 
--- Loader thread run time % of hour
select 'Avg Loader Pct Hour Run/Thread=', TO_CHAR(round((avg(value_average)/3600)*100,2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Management_Loader_Status' and
m.metric_column = 'load_run' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;
 
--- Rollup Rows per hour
select 'Avg Rollup Rows/Hour=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'DBMS_Job_Status' and
m.metric_column = 'jobthroughput' and
h.key_value = 'Rollup' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;

--- Rollup % of hour run
select 'Avg Rollup Pct Hour Run=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'DBMS_Job_Status' and
m.metric_column = 'jobprocessing' and
h.key_value = 'Rollup' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;

--- Number of job dispatchers (hint: equal to number of Management Servers)
select  'Job Dispatchers=', TO_CHAR(count(distinct key_value))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Job_Dispatcher_Performance' and
m.metric_column = 'throughput' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ');

 
--- Job steps processed per second
select 'Avg Job Steps/Second=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Job_Dispatcher_Performance' and
m.metric_column = 'throughput' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;

 
---  Notifications Per Second
select 'Avg Notifications/Second=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Notification_Performance' and
m.metric_column = 'notificationthroughput' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;

--- Notification % of hour run
select 'Avg Notification Pct Hour Run=', TO_CHAR(round(avg(value_average),2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Notification_Performance' and
m.metric_column = 'notificationprocessing' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')
group by metric_name, metric_column;

--- Severities per hour
select 'Avg Severities Per Hour=', TO_CHAR(round(avg(count(*)),2)) as sev_count from mgmt_severity
where collection_timestamp > sysdate - 7
group by trunc(collection_timestamp, 'HH');

--- OMS Host CPU Util
select 'Avg Management Server Host CPU=', TO_CHAR(round(avg(value_average),2)), t.target_name
from mgmt_metrics_1hour h, mgmt_targets t where
h.target_guid in (select target_guid from mgmt_targets t where
target_type = 'host' and
target_name in (select substr(host_url,1,instr(host_url, '_Management_Service',-1,1)-1)
                                 from mgmt_oms_parameters)) and
h.metric_guid = (select m.metric_guid from mgmt_metrics m where
                          m.target_type = 'host' and
                          m.metric_name = 'Load' and
                          m.metric_column = 'cpuUtil'and
                          t.type_meta_ver = m.type_meta_ver and
                         (t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
                         (t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
                         (t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
                         (t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
                         (t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')) and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7
group by t.target_name;

--- Create a small table to get DB Guids. GV$INSTANCE performance is inconsistant across db versions.
create table mgmt_temp_vsign_db_guids as select h.target_guid from mgmt_targets h where
                   h.target_type = 'host' and
                   h.target_name in (select s.target_name from mgmt_targets s, gv$instance g where
                                                      s.target_type = 'host' and
                                                      s.target_name like g.host_name || '%');

--- Run CBO stat analysis on temp table for performance.
exec dbms_stats.gather_table_stats('SYSMAN','MGMT_TEMP_VSIGN_DB_GUIDS',NULL, DBMS_STATS.AUTO_SAMPLE_SIZE, FALSE,'FOR ALL COLUMNS SIZE AUTO',NULL,'GLOBAL',TRUE,NULL,NULL,NULL);

--- EM Repository CPU
select 'Avg Management Repository Host CPU=', TO_CHAR(round(avg(value_average),2)), t.target_name
from mgmt_metrics_1hour h, mgmt_targets t where
h.target_guid in (select target_guid from mgmt_temp_vsign_db_guids) and
h.metric_guid = (select m.metric_guid from mgmt_metrics m where
                           m.target_type = 'host' and
                           m.metric_name = 'Load' and
                           m.metric_column = 'cpuUtil'and
                           t.type_meta_ver = m.type_meta_ver and
                          (t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
                          (t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
                          (t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
                          (t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
                          (t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ')) and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-7
group by t.target_name;

--- Repository Used Space
select 'Repository Used Space (GB)=',  TO_CHAR(round(max(value_average)/1000,2))
from mgmt_metrics_1hour h, mgmt_metrics m, mgmt_targets t where
t.target_type = 'oracle_emrep' and
m.target_type = t.target_type and
m.metric_name = 'Configuration' and
m.metric_column = 'usedRepSpace' and
m.metric_guid = h.metric_guid and
h.target_guid = t.target_guid and
rollup_timestamp > sysdate-1 and
t.type_meta_ver = m.type_meta_ver and
(t.category_prop_1 = m.category_prop_1 OR m.category_prop_1 = ' ') and
(t.category_prop_2 = m.category_prop_2 OR m.category_prop_2 = ' ') and
(t.category_prop_3 = m.category_prop_3 OR m.category_prop_3 = ' ') and
(t.category_prop_4 = m.category_prop_4 OR m.category_prop_4 = ' ') and
(t.category_prop_5 = m.category_prop_5 OR m.category_prop_5 = ' ');


--- Drop the temp table
drop table mgmt_temp_vsign_db_guids;
 
set heading on
column Module format a15
column Agent format a20
column error_msg format a60

PROMPT ------------------------------------------------------------------------------------------
PROMPT 
PROMPT **** The number of management Errors that have occurred per Module in the past 24 hours
 SELECT module_name Module, COUNT(*) 
        FROM   mgmt_system_error_log
        WHERE  occur_date> SYSDATE-1
        GROUP BY module_name
        ORDER BY module_name;

PROMPT **** The Following Errors have occurred in the past two days
alter session set nls_date_format='MM/DD/YYYY HH24:MI';

select occur_date, module_name Module, emd_url Agent, error_msg 
  from mgmt_system_error_log
 where occur_date > sysdate - 2
 order by occur_date;


 
PROMPT ------------------------------------------------------------------------------------------

PROMPT **** Check the status of all DBMS_JOBS and look for broken jobs or next_run data that is already in the past. 
column Job format a8
column interval format a25
column what format a45

        SELECT to_char(job) Job, TO_CHAR(next_date,'DD-MON-YYYY HH24:MI:SS') next_run, 
           interval, broken, what
        FROM   user_jobs
        ORDER BY next_date DESC;

PROMPT  -----------------------------------------------------------------------------------------

PROMPT **** Show the performance statistics of all jobs over the last 24 hours:
column Job_name format a50
     SELECT job_name, COUNT(*) n_recs,
            MIN(duration) min_duration, MAX(duration) max_duration, ROUND(AVG(duration),2) avg_duration
     FROM   mgmt_system_performance_log
     WHERE  is_total = 'Y'
       AND  time> SYSDATE-1
     GROUP BY job_name
     ORDER BY job_name;

 
PROMPT ------------------------------------------------------------------------------------------

PROMPT **** Overview of all Agent XML activity of the last day:
SELECT module, cnt "Number", TO_CHAR(FLOOR(mins/60),'999')||':'||TO_CHAR(MOD(mins,60),'09')||':'||TO_CHAR(MOD(secs,60),'09') "Time Spent" 
FROM   (SELECT module, COUNT(*) cnt, ROUND(SUM(duration)/1000) secs, FLOOR(SUM(duration)/60000) mins 
        FROM   mgmt_system_performance_log
        WHERE  job_name = 'LOADER'
          AND  time > SYSDATE-1
        GROUP BY module)
ORDER BY cnt DESC;

spool off

