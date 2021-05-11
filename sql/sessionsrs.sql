col RBS format a5 trunc
col SID format 9990
col USER format a10 trunc
col COMMAND format a78 trunc
col status format a6 trunc

SELECT r.name "RBS", s.sid, s.serial#, s.username "USER", t.status,
      t.cr_get, t.phy_io, t.used_ublk, t.noundo,
      substr(s.program, 1, 78) "COMMAND"
FROM   sys.v_$session s, sys.v_$transaction t, sys.v_$rollname r
WHERE  t.addr = s.taddr
 and  t.xidusn = r.usn
ORDER  BY t.cr_get, t.phy_io
/