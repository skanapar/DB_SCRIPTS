SELECT v.status, v.SID,v.serial#,io.block_changes,event, module,v.sql_id FROM v$sess_io io,v$session v WHERE io.SID=v.SID AND v.saddr IN (SELECT saddr FROM dba_datapump_sessions) ORDER BY io.BLOCK_CHANGES
/
