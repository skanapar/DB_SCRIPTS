BREAK ON DATABASE skip 1
col elapsed for 99,999.9
SELECT name "DataBase", bs_key, set_count, status,
DECODE(backup_type,'D','DATABASE','L','ARCHIVE LOG','I','INCREMENTAL') TYPE,
incremental_level "Level",
TO_CHAR(start_time, 'MM/DD/YY-HH24:MI') "Start Time",
elapsed_seconds/60 "Elapsed"
FROM rc_backup_set a, rc_database b
WHERE start_time > sysdate - 14
AND name LIKE UPPER('&DataBase%')
AND a.db_key = b.db_key
AND elapsed_seconds BETWEEN 0 AND 86399
ORDER BY 1, 7
/
