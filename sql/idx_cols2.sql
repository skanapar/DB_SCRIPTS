set pagesize 1000
break on table_name on index_owner on index_name skip 1
set linesize 132
column table_name format a20 wrapped
column index_name format a30
column column_name format a30
column index_owner format a15
column index_type format a10
column column_position heading "Pos" format 999
select a.index_owner,a.table_name,a.index_name,a.column_name,a.column_position ,b.uniqueness,descend, b.index_type
from all_ind_columns a ,all_indexes b
where
a.table_name = b.table_name
and a.index_owner = b.owner
and a.index_name = b.index_name
and b.table_name = upper('&table_name')
order by index_name,column_position;
