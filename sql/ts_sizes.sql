select TABLESPACE_NAME, count(*) df_num, sum(BYTES)/1048576 total_mb from dba_data_files
group by TABLESPACE_NAME
/
