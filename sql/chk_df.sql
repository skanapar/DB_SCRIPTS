set line 120
column file_name format a55
select FILE_NAME, FILE_ID, BYTES/1048576 mb, AUTOEXTENSIBLE, MAXBYTES, INCREMENT_BY from dba_data_files where tablespace_name='USL_IDX_MSSM'
order by FILE_NAME
/
