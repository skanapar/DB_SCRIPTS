select 'alter index FINANCIALS.'||INDEX_NAME||' rebuild subpartition '||SUBPARTITION_NAME||' tablespace usl_acct_events online;' from dba_ind_subpartitions where SUBPARTITION_NAME in (select partition_name  from dba_segments where tablespace_name='USL_ACCT_EVENTS_IDX' and bytes > 1048576*1024) order by INDEX_NAME
/
