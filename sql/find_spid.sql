SELECT s.sid, s.serial#, s.username, s.osuser, p.spid, s.machine, p.terminal, s.program
FROM v$session s, v$process p
WHERE s.paddr = p.addr;
