set pagesize 200 linesize 200
col username for a14
col sql_text  format a1000           heading 'SQL statement'  wrap newline
col Total_Execs for 9999999999
col Latency(ms) for 9,999,999
select b.username, a.executions Total_Execs, c.ExecPerSecs "Latency(ms)",  a.hash_value, c.address, a.sql_text
from v$sqlarea a, dba_users b,
(select ADDRESS, HASH_VALUE, ExecPerSecs
from (select ADDRESS, HASH_VALUE, sum(elapsed_time/1000)/sum(DECODE(executions,0,1,executions)) ExecPerSecs
	from v$SQL_PLAN_STATISTICS_ALL
	group by ADDRESS, HASH_VALUE
	order by 3 desc)
where rownum <11) c
where b.user_id= a.PARSING_SCHEMA_ID
--and a.HASH_VALUE = 2013064289
and b.username not in ('SYS', 'SYSTEM', 'PATROL', 'PERFSTAT', 'EADBA','OPS$ORACLE')
and c.ADDRESS = a.ADDRESS
and c.HASH_VALUE = a.HASH_VALUE
order by 3 desc;
