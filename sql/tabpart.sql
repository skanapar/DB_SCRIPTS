set linesize 200
set pagesize 200
col TABLE_NAME for a35
col PARTITION_NAME for a35
col TABLESPACE_NAME for a35

select TABLE_NAME,PARTITION_NAME,TABLESPACE_NAME,num_rows,last_analyzed
from dba_tab_partitions
order by 1
/
