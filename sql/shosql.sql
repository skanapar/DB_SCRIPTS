clear screen

set lines 3000
set long 3000
set pagesize 100

col sql_text for a45 wrap
col osuser for a10
col disk_reads hea 'DISK|READS'
col burden hea 'BURDEN' format 99999.99
column spid format 9999
column process format 9999
column sid format 9999

select sql_text,s.sid, s.osuser, s.process, p.spid,  q.disk_reads, q.executions, s.status,
       (q.disk_reads/decode(q.executions,0,1,q.executions)) burden
  from v$session s, v$sqlarea q, v$process p
 where q.hash_value = s.sql_hash_value
   and s.paddr = p.addr
   and spid like '%&spid%'
 and status='ACTIVE'
  -- and s.username not in ('SYS')
order by s.status;
