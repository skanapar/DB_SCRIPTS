set lines 200
col status format a10
SELECT name, status, (select name from v$database) db_name
 FROM DBA_DV_STATUS
/
