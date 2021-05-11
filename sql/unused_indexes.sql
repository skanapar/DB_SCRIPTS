set pages 999
set verify off
select i.index_name, count(object_name)
from dba_indexes i, gv$sql_plan s
where i.index_name = s.object_name(+)
and i.owner like nvl('&owner',i.owner)
and i.table_name like nvl('&table_name',i.table_name)
group by i.index_name
having count(object_name) > 0
order by 2 desc
/
