compute sum of mb on report
break on report
set lines 132 pages 132
SELECT s.username, s.sid,  u.TABLESPACE, u.CONTENTS, u.extents, u.blocks, u.blocks*8/1024 mb
  FROM v$session s, v$sort_usage u
  WHERE s.saddr = u.session_addr;
