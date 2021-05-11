connect / as sysdba

alter session set container=&PDB_TO_CONFIGURE_DV
/
GRANT CREATE SESSION, SET CONTAINER TO c##dbv_owner_root CONTAINER = CURRENT;
 GRANT CREATE SESSION, SET CONTAINER TO c##dbv_acctmgr_root CONTAINER = CURRENT;


BEGIN 
CONFIGURE_DV (
dvowner_uname=> 'c##dbv_owner_root', 
dvacctmgr_uname => 'c##dbv_acctmgr_root');
END;
/
@ ?/rdbms/admin/utlrp.sql
