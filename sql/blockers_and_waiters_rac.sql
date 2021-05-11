--blockers_and_waiters_rac.sql
--7/8/04 J. Adams (Based on a searchoracle.com script)
--Find sessions that are holding or waiting for table-level locks.
--7/6/10 - Modified to include the mode of the lock encountered.
--2/28/13 - Streamlined query to remove unnecessary information

set linesize 150
set pages 50
column "SID"          format 9999
column "SER"          format 99999
column "OS User"      format A7 
column "SQL Text"     format A40 word wrap
column "Mode"         format A20
column "Status"       format A20
column "Node"         format A10

--spool c:\blockers_and_waiters.log

select
  s.sid "SID",
  s.serial# "SER",
  s.osuser "OS User",
  s.machine "Node",
  decode (s.lockwait, null, 'Have Lock(s)', 'Waiting for <' || b.sid || '>') "Status",
  decode (l.lmode,1,'NULL',2,'Row Share',3,'Row Exclusive',4,'Share',5,'Shared Row',6,'Exclusive',l.lmode) "Mode",
  s.sql_id "SQL",
  substr (c.sql_text, 1, 150) "SQL Text"
from 
  gv$lock l,
  gv$lock d,
  gv$session s,
  gv$session b,
  gv$process p,
  gv$transaction t,
  sys.dba_objects o,
  gv$open_cursor c
where l.sid = s.sid
  and o.object_id (+) = l.id1
  and c.hash_value (+) = s.sql_hash_value
  and c.address (+) = s.sql_address
  and s.paddr = p.addr
  and d.kaddr (+) = s.lockwait
  and d.id2 = t.xidsqn (+)
  and b.taddr (+) = t.addr
  and l.type = 'TM'
group by
  s.osuser,
  s.machine,
  s.sql_id,
  p.spid,
  s.process,
  s.sid,
  s.serial#,
  decode (s.lockwait, null, 'Have Lock(s)', 'Waiting for <' || b.sid || '>'),
  decode (l.lmode,1,'NULL',2,'Row Share',3,'Row Exclusive',4,'Share',5,'Shared Row',6,'Exclusive',l.lmode),
  substr (c.sql_text, 1, 150)
order by 
  decode (s.lockwait, null, 'Have Lock(s)', 'Waiting for <' || b.sid || '>') desc,
  s.sid asc;

--spool off;
