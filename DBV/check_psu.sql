set lines 200
col description format a50
col action format a20
SELECT description, action, TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time, status
FROM   sys.dba_registry_sqlpatch
/
