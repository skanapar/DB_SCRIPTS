select t.TABLESPACE_NAME, 
(select sum(bytes)/1048576 tb from dba_data_files where tablespace_name=t.tablespace_name) total_mb, 
(select sum(bytes)/1048576 fb from dba_free_space where tablespace_name=t.tablespace_name) free_mb
from dba_tablespaces t 
/
