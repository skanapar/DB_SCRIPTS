set echo on;
spool create_db_link_source.log
create public database link    connect to mig_user identified by xxxxxx using '(DESCRIPTION= (ADDRESS=(PROTOCOL=tcp)(HOST= &host_name)(PORT=1521)) (CONNECT_DATA= (SERVICE_NAME=&servcie_name) ))';
spool off;
