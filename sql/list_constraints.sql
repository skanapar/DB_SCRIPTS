set long 30
set lines 140
set pages 132
column constraint_name format a30 heading "constraint|name"
column delete_rule format a9 heading "del|rule"
column table_name format a18 heading "table name"
column column_name format a20 heading "column name"
column type format a10 heading "Constraint|Type"
column position format 999 heading "pos"
accept tabname default '%' -
prompt 'press enter for all tables or enter a table name: '
--break on table_name  on constraint_name skip 1
break on report on table_name  skip 1
--break on constraint_name skip page

select con.table_name,
       col.constraint_name,
       col.column_name,
       col.position,
       decode (con.constraint_type, 'P','primary','R','foreign','U','unique','C','check') "TYPE",
       search_condition Cond
from   dba_cons_columns col,
       dba_constraints con
where  col.table_name like upper('&tabname')
and    constraint_type <> 'r'
and    col.table_name = con.table_name
and    col.constraint_name = con.constraint_name
order by 1,2,5,4;
