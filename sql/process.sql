select a.sid, a.serial#, a.username, a.paddr, b.pid, b.spid, b.program
 from v$session a, v$process b
where a.paddr=b.addr
/
