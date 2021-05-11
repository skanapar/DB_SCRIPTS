column time format a35
column name format a20
select GUARANTEE_FLASHBACK_DATABASE, STORAGE_SIZE, TIME,  NAME, PDB_RESTORE_POINT, con_id from v$restore_point
/
