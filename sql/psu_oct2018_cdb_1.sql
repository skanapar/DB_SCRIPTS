whenever sqlerror exit 99
set serveroutput on
declare
v_now number;
v_sql varchar2(400);
begin
select to_char(sysdate,'YYYYMMDDHH24MI')
into v_now from dual;
v_sql := 'create table registry$sqlpatch_'||v_now||' as select * from registry$sqlpatch' ;
dbms_output.put_line (v_sql);
execute immediate v_sql;
end;
/
exec dbms_pdb.exec_as_oracle_script('drop table registry$sqlpatch');
@$ORACLE_HOME/rdbms/admin/catsqlreg.sql
