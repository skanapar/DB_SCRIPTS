undefine pdb
whenever sqlerror exit 99
alter session set container=&1 ;
 show con_name  
begin
if upper('&1') like 'PDB$SEED'
then
execute immediate 'alter pluggable database PDB$SEED close instances=all';
execute immediate 'alter pluggable database PDB$SEED open instances=all';
end if;
end;
/
set serveroutput on
declare
v_now number;
v_sql varchar2(400);
begin
select to_char(sysdate,'YYYYMMDDHH24MISS')
into v_now from dual;
v_sql := 'create table registry$sqlpatch_'||v_now||' as select * from registry$sqlpatch' ;
dbms_output.put_line (v_sql);
execute immediate v_sql;
end;
/

 exec dbms_pdb.exec_as_oracle_script('drop table registry$sqlpatch');
@$ORACLE_HOME/rdbms/admin/catsqlreg.sql

 alter pluggable database &1 close immediate instances=all;
 alter pluggable database &1 open upgrade;
 
