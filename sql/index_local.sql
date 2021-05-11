prompt &1 - Object owner
prompt 
define object_owner = &1

select a.owner||'.'||a.table_name table_name, a.index_name, a.partitioned, b.locality
from dba_indexes a, dba_part_indexes b
where a.index_name = b.index_name(+)
and a.owner = b.owner(+)
and a.owner = upper('&&object_owner')
order by a.owner, a.table_name
/
