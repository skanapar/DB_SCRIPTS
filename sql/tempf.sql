--aspool dataf
column FILE_NAME format a48
column TABLESPACE_NAME format a20
break on tablespace_name skip 1
compute sum of Mb on tablespace_name
select TABLESPACE_NAME, FILE_NAME,BYTES/1048576 Mb, status, maxbytes/1048576 maxMb, increment_by from dba_temp_files 
order by TABLESPACE_NAME, FILE_NAME
/
--spool off


