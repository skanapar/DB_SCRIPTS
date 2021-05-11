select round( (sysdate - oldest_flashback_time)*24*60,1) from v$flashback_database_log
/
