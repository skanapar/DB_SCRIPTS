set verify off
break on column_name
select distinct column_name, table_name
from dba_tab_columns
where column_name like nvl('&column_name',column_name)
order by 1,2
/
