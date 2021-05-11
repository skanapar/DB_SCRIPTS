set linesize 132
column sql_text format a80 wrapped
column username format a12
select sql_text, s.username, sid, s.serial#, p.spid
from v$session s, v$sqlarea sa, v$process p
where s.sql_address = sa.address
and s.sql_hash_value = sa.hash_value
and s.paddr = p.addr
and p.spid = '&OsProcessId';
