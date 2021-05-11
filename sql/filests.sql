set pages 50
set line 200
column file_name format a80
compute sum of Mbytes on report
break on report
select a.tablespace_name, file_name, bytes, bytes/1048576 Mbytes 
from dba_tablespaces a, dba_data_files b
where b.tablespace_name=a.tablespace_name
/
