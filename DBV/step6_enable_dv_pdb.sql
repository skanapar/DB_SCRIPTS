CONNECT c##dbv_owner_root

alter session set container=&&PDB_NAME
/
EXEC DBMS_MACADM.ENABLE_DV;
connect / as sysdba

ALTER PLUGGABLE DATABASE &&PDB_NAME CLOSE IMMEDIATE instances=all; 
ALTER PLUGGABLE DATABASE  &&PDB_NAME OPEN instances=all;

alter session set container=&&PDB_NAME
/

col status format a30
col name format a30

SELECT * FROM DBA_DV_STATUS
/
