select * from dba_lobs
where table_name like nvl('&table_name',table_name)
and column_name like nvl('&column_name',column_name)
/
