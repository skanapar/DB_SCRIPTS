set echo on
set termout on
set feedback on
alter pluggable database &1 close immediate instances=all;
alter pluggable database &1 open upgrade;

alter session set container=&1;

@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/catupgrd.sql
connect / as sysdba
alter pluggable database &1 close immediate instances=all;
alter pluggable database &1 open immediate instances=all;
host srvctl start service -d ${ORACLE_UNQNAME}

