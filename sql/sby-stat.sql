set feedback off echo off
set lines 90 pagesize 99
col type format a38
col ITEM format a25
col comments format a20
spool $HOME/status.log append
set pagesize 0
select '=================================================================================' from dual;
select 'Instance: '||instance_name from v$instance;
select '=================================================================================' from dual;
select 'MRP Active:                 '||decode(count(*),0,'MRP not active','MRP is active') from v$managed_standby where process like 'MRP%';
select 'Current SCN:                '||current_scn  from v$database;
select 'Minimum file header SCN:    '||min(fhscn) from x$kcvfh where fhscn>0;
select 'Incremental backup SCN:     '||min(scn) from (select to_number(current_scn) as scn from v$database union select to_number(fhscn) from x$kcvfh where fhscn>0);
select 'Control file change SCN:    '||controlfile_change# from v$database;
select 'Control file time:          '||to_char(controlfile_time, 'DD-MON-YYYY HH24:MI:SS')  from v$database;
select 'Database role:              '||database_role from v$database;
select 'Database Open Mode:         '||open_mode from v$database;
select 'Log sequence gap:           '||(r.sequence#-m.sequence#)||' log files'||'                  '||m.sequence#||'-'||r.sequence#||' sequence gap'
from v$managed_standby r, v$managed_standby m where m.process='MRP0' and r.process='RFS' and r.client_process='LGWR';
select 'Last applied redo time:     '||to_char(timestamp,'DD-MON-YYYY HH24:MI') from v$recovery_progress where item like 'Last%';
select 'Last applied redo sequence: '||(sequence#) from v$managed_standby where process='MRP0' ;
select unique 'Current database lag:       '||round((to_number(start_time-timestamp)*24))||' hours.' from v$recovery_progress where item like 'Last%';
select 'SGA max size:               '||display_value from v$parameter where name='sga_max_size';
select 'SGA target size             '||display_value from v$parameter where name='sga_target';
select 'Database cache size         '||display_value from v$parameter where name='db_cache_size';
select 'Safe to delete until:       '||(sequence#-1) from V$MANAGED_STANDBY where process  like 'MRP0%';
set pagesize 99
select PROCESS, CLIENT_PROCESS, SEQUENCE#,BLOCK#,BLOCKS,DELAY_MINS,status from V$MANAGED_STANDBY where process not like 'ARCH%' order by process desc;
set pagesize 0
select '=================================================================================' from dual;
select 'Instance: '||instance_name from v$instance;
select '=================================================================================' from dual;
select ' ' from dual;
select ' ' from dual;
spool off

exit

