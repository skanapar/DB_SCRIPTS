exec dbms_stats.gather_system_stats('EXADATA');
BEGIN

DBMS_AUTO_TASK_ADMIN.disable(
    client_name => 'auto space advisor',
    operation   => NULL,
    window_name => NULL);
END;
/

BEGIN
  dbms_auto_task_admin.disable(
    client_name => 'sql tuning advisor',
    operation   => NULL,
    window_name => NULL);
END;
/
alter system set awr_pdb_autoflush_enabled=true; 

exec DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
