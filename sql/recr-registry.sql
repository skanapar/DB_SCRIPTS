create table registry$sqlpatch_org as select * from registry$sqlpatch ;
exec dbms_pdb.exec_as_oracle_script('drop table registry$sqlpatch');
@$ORACLE_HOME/rdbms/admin/catsqlreg.sql

