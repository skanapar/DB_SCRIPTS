set verify off
set feedback off
set echo off
set heading on
set linesize 200
set pagesize 200
col sql_text for a75 wrap
spool /tmp/tmpTopSQL.lst
select sql_text, q.BUFFER_GETS, q.PARSE_CALLS, q.DISK_READS, q.EXECUTIONS, spid
from    v$sqlarea q,
        v$process p,
        v$session s
where spid = &1
and s.paddr = p.addr
and q.hash_value = s.sql_hash_value;
spool off
exit;
