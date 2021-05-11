select to_char(round( (sysdate - oldest_flashback_time)*24*60,1),'99999.9') from v$flashback_database_log ;
show parameter recovery
show parameter flashback