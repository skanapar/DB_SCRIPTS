select s.sid, s.serial#, s.OSUSER, s.MODULE, s.MACHINE, t.status "transaction status", 
t.start_time "trans. start time",t.noundo "No Undo ?", t.used_ublk "Undo Blocks", 
trunc((t.used_ublk*b.bytes)/1048576,2) "Undo MB", t.LOG_IO "Log IO", t.phy_io "Phys IO", 
s.PROCESS, s.STATUS "session"
from 
v$transaction t, v$session s,
(select to_number(value) "BYTES" from v$parameter where name = 'db_block_size') b
where s.SADDR = t.ses_ADDR
order by t.used_ublk desc
/
