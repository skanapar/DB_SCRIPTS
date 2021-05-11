select index_name, partition_name, status from dba_ind_subpartitions where status NOT IN ('VALID', 'USABLE', 'N/A')
/
