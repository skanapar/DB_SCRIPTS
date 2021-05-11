set pagesize 999
set lines 150
col username format a13
col prog format a10 trunc
col sql_text format a41
col sid format 999
col child for 99999
col avg_etime for 999,999.99
select sid, substr(program,1,19) prog, address, hash_value, b.sql_id, sql_child_number child, executions execs,
(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
sql_text
from v$session a, v$sqlarea b
where status = 'ACTIVE'
and username is not null
and a.sql_address = b.address
and a.sql_hash_value = b.hash_value
and audsid != SYS_CONTEXT('userenv','sessionid')
/

