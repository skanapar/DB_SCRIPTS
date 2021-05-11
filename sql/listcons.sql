set lines 132
set pages 1000
set echo off
accept tabname default '%' -
prompt 'Press Enter for all tables or enter a table name: '
break on report on table_name  skip 1

select uc.table_name table_name,uc.constraint_name,
       decode(uc.constraint_type
             ,'C','CHECK'
             ,'P','PK'
             ,'R','FK'
             ,'U','UNIQUE'
             ,'V','with check option') TYPE
--||' | '||concols(uc.constraint_name) "Table | Constr | Type | Cols"
  from dba_constraints uc
 where uc.table_name like upper('&tabname')
 order by uc.table_name, uc.constraint_name
/

set echo on
