set line 180
column high_value format a100
column table_owner format a15
column partition_position format 999
select a.table_owner, a.table_name, a.partition_position as POS, a.high_value from dba_tab_partitions a, 
(select table_owner, table_name, max(partition_position) as position from dba_tab_partitions
where table_owner not in ('SYS','SYSTEM','ADMIN')
group by table_owner, table_name) b
where a.table_owner=b.table_owner
and a.table_name=b.table_name
and a.partition_position=b.position
and a.high_value is not null
/
