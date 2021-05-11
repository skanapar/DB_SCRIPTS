set echo off
set feedback off
set pagesize 500
set linesize 200
spool $OUTFILE
prompt
prompt  **********************************************************************************
prompt  ** Instance Info *****************************************************************
prompt  **********************************************************************************
col INSTANCE_NAME for a15
col HOST_NAME for a15
col status for a15
col STARTUP_TIME for a15
select INSTANCE_NAME, HOST_NAME, status ,STARTUP_TIME
from v$instance
/

prompt
prompt
prompt  **********************************************************************************
prompt  ** Logs Trends Analysis for Last Week (Day Wise Aggredates) **********************
prompt  **********************************************************************************
col Date_Archived for a15
col Total_Bytes_MB for 99999999999
col Logs_Generated for 99999999999
select  trunc(COMPLETION_TIME)                  Date_Archived,
        round(sum(BLOCKS*BLOCK_SIZE/1024/1024)) Total_Bytes_MB,
        count(*)                                Logs_Generated
from v$archived_log
group by trunc(COMPLETION_TIME)
having trunc(completion_time) <= trunc(sysdate) and trunc(completion_time) > trunc(sysdate) - 7
order by trunc(COMPLETION_TIME) desc
/

prompt
prompt
prompt  **********************************************************************************
prompt  ** Top-10 Archive Activity Time Analysis for Last two days (Hourly Aggredates) ***
prompt  **********************************************************************************
col Time_Archived for a20
col Total_Bytes_MB for 99999999999
col Logs_Generated for 99999999999
select rownum Serial#, Time_Archived, Total_Bytes_MB, Logs_Generated
from
(select to_char(COMPLETION_TIME, 'DD-MON-yyyy @ hh24AM') Time_Archived,
        round(sum(BLOCKS*BLOCK_SIZE/1024/1024))         Total_Bytes_MB,
        count(*)                                        Logs_Generated
from v$archived_log
where trunc(COMPLETION_TIME) in (trunc(sysdate), trunc(sysdate)-1 )
group by to_char(COMPLETION_TIME, 'DD-MON-yyyy @ hh24AM')
order by 2 desc, 1 desc)
where rownum < 11
/

prompt
prompt
prompt  **********************************************************************************
prompt  ** Next Extent Failure Alarm *****************************************************
prompt  **********************************************************************************
col segment_name format a50
select owner,segment_name, next_extent/1024/1024 "Next_Extent(MB)", s.tablespace_name,max_free_bytes
  from sys.dba_segments s,
       (select tablespace_name,max(bytes) max_free_bytes
          from sys.dba_free_space
         group by tablespace_name) f
 where s.next_extent > f.max_free_bytes
   and s.tablespace_name=f.tablespace_name
/

prompt
prompt
prompt  **********************************************************************************
prompt  ** Space Usage Analysis **********************************************************
prompt  **********************************************************************************
col TABLESPACE_NAME for a25
col MB for 9999999999
select TABLESPACE_NAME, floor(sum(bytes/1024/1024)) MB
from dba_free_space group by TABLESPACE_NAME
order by 2 desc
/

prompt
prompt
prompt  **********************************************************************************
prompt  ** End of Analysis ***************************************************************
prompt  **********************************************************************************
spool off
exit
