set trimspool on
set pagesize 10000 linesize 200
col username for a14
col executions for 9999999  heading TOTAL_EXEC
col execpersecs for 9999999 heading 'Latency(ms)'
col disk_reads for  9999999999 heading 'disk_reads(per exec)'
col buffer_gets for 9999999999 heading 'buffer_gets(per exec)'
col sql_text  format a100  heading 'SQL_TEXT'  wrap newline

select 
       b.username, 
       a.executions, 
       c.execpersecs, 
       a.disk_reads/DECODE(executions,0,1,executions) disk_reads,
       a.buffer_gets/DECODE(executions,0,1,executions) buffer_gets,
       a.sql_text
from v$sqlarea a, dba_users b,
(select address, hash_value, EXECPERSECS
   from (select address, hash_value, sum(elapsed_time/1000)/sum(DECODE(executions,0,1,executions)) EXECPERSECS
           from v$SQL_PLAN_STATISTICS_ALL
                group by address, hash_value
                order by 3 desc)
where rownum <26) c
where b.user_id= a.parsing_schema_id
and b.username not in ('SYS', 'SYSTEM', 'PATROL', 'PERFSTAT', 'EADBA','OPS$ORACLE')
and c.address = a.address
and c.hash_value = a.hash_value
order by disk_reads desc;
