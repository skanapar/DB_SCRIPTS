whenever sqlerror continue
set termout on
set echo on
alter pluggable database &1 close immediate instances=all;

alter session set container=&1
/
startup open restrict;
alter pluggable database &1 rename global_name to &2;
host sleep 60
#host srvctl stop database -d ${ORACLE_UNQNAME}
#host srvctl start database -d ${ORACLE_UNQNAME}
#host srvctl start service -d ${ORACLE_UNQNAME}
whenever sqlerror exit 99
whenever oserror exit 98

connect / as sysdba
alter session set container=&2;

alter pluggable database &2  close immediate instances=all;

alter pluggable database &2 open instances=all;


@?/rdbms/admin/utlrp.sql  --temporary band aid

exit; 
