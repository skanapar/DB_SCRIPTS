connect c##dbv_owner_root
EXEC DBMS_MACADM.ENABLE_DV (strict_mode => 'n');
conn / as sysdba
set lines 200
SELECT * FROM DBA_DV_STATUS
/
