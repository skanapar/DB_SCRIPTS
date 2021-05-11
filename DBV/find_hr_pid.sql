set lines 160
col program format a22
col username format a20
col osuser format a10
col machine format a20
SELECT s.inst_id, s.sid, s.serial#, s.username, s.osuser,p.pid, p.spid, s.machine,  s.program, process
FROM gv$session s, gv$process p
WHERE s.paddr = p.addr
and p.inst_id=s.inst_id
and s.username ='HR';
