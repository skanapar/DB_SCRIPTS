set numwidth 8
set lines 132
set pages 140
column event format a30 tru 
column program format a25 tru 
column username format a15 tru 
column OS_USER for a8
column sec format 9999
column INST_ID format 9
column SID format 999
column SERIAL#  format 999
column SPID  format 999999

select p.inst_id, s.sid, s.serial#, p.pid, p.spid, p.program, s.username,  
p.username os_user, sw.event, sw.seconds_in_wait sec   
from gv$process p, gv$session s, gv$session_wait sw 
where (p.inst_id = s.inst_id and p.addr = s.paddr) 
and (s.inst_id = sw.inst_id and s.sid = sw.sid) 
and sw.event not like '%SQL*Net%'
and sw.event not like '%timer%'
and sw.event not like '%idle%'
and sw.event not like '%Idle%'
and sw.event not like '%PX Deq%'
and sw.event not like '%rdbms ipc%'
and sw.event not like '%Null event%'
and sw.event not like '%file open%'
and sw.event not like '%PX Idle Wait%'
and sw.event not like '%timer%'
and sw.event not like 'gcs remote message'
and sw.event not like 'log file sync'
and sw.event not like 'ges remote message'
order by p.inst_id, s.sid;
