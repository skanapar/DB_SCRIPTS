clear screen
set verify off 
set feedback on
col TABLE_NAME for a20
col high_value for a15
col PARTITION_NAME for a20 
col TABLESPACE_NAME for a20

break on tablespace_name on table_name skip 1

accept table_name prompt "Enter Table Name (Enter for All) : "

select 
tablespace_name, table_name, partition_name, num_rows, high_value 
from user_tab_partitions
where table_name like upper('&table_name%')
order by 1,table_name,partition_name;
prompt Sub Partitions ....!!!!
select tablespace_name,table_name,partition_name,subpartition_name from user_tab_subpartitions
where table_name like upper('&table_name%');
