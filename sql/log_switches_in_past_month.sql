--log_switches_in_past_month.sql
--Query for log switches over the past month

set linesize 200

select a.logswitches "SWITCHES_IN_1_MONTH",
round((a.logswitches/30)) "AVG_SWITCHES_PER_DAY", 
to_char(b.bytes/1024/1024,'999,999,999,999,990') "MBYTES_PER_LOG", 
to_char(sum(a.logswitches*b.bytes)/1024/1024,'999,999,999,999,990') "TOTAL_MB_MONTH",
to_char((sum(a.logswitches*b.bytes)/1024/1024)/30,'999,999,999,999,990') "AVG_DAILY_MB"
from 
(select count(1) "LOGSWITCHES" from v$loghist
where trunc(first_time) >= (sysdate - 30)) a, 
(select bytes from v$log where rownum < 2) b
group by a.logswitches, b.bytes
/


