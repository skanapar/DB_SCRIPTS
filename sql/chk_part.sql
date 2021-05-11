select partition_name, partition_position,high_value from dba_tab_partitions where table_name=upper('&1')
order by partition_position desc;

