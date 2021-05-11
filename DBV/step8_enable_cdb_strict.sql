connect c##dbv_owner_root
EXEC DBMS_MACADM.ENABLE_DV (strict_mode => 'Y');
conn / as  sysdba
SELECT * FROM DBA_DV_STATUS
/
