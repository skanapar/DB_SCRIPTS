SET VERIFY OFF
define idx_owner = &1

select * from 
(
select owner as index_owner, index_name, null as partition_name, null as subpartition_name, status from dba_indexes where owner=UPPER('&&idx_owner')
union
select index_owner, index_name, partition_name, null as subpartition_name, status from dba_ind_partitions where (index_owner,index_name) in 
  (select owner, index_name from dba_indexes where owner=UPPER('&&idx_owner'))
union
select index_owner, index_name, partition_name, subpartition_name, status from dba_ind_subpartitions where (index_owner,index_name) in 
  (select owner, index_name from dba_indexes where owner=UPPER('&&idx_owner'))
) tab
where status not in ( 'VALID', 'USABLE', 'N/A' )
/
