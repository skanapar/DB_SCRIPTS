select 'alter index FINANCIALS.'||index_name||' rebuild partition '||partition_name||' tablespace USL_DATA_MSSM parallel 8;' from dba_ind_partitions where index_name='IDX_SL_RK_KEY_VALUE' order by partition_position desc
/
