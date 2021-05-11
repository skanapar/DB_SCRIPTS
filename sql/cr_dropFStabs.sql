select 'alter table land.'||r.table_name||' drop constraint '||r.constraint_name||'_PK;'
from dba_tables t, dba_constraints s, dba_constraints r
where 
t.table_name = s.table_name
and s.constraint_name = r.r_constraint_name
and
t.table_name in (select table_name from dba_tables where table_name like 'S%'
or table_name like 'F%')
and (t.table_name, t.owner) not in (select table_name, owner from sde.layers)
and t.owner='LAND'
/
