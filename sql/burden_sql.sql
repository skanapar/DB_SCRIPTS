set linesize 132
set pagesize 1000

column sid heading "Sid" format 9999
column sql_text format a60
column burden format 9999.99

select s.sid,  sql_text, q.disk_reads, q.executions,
       (q.disk_reads/decode(q.executions,0,1,q.executions)) burden
  from v$session s, v$sqlarea q, v$process p
 where q.hash_value = s.sql_hash_value
and s.username not in('SYS','SYSTEM','EADBA')
   and s.paddr = p.addr
order by burden desc;
