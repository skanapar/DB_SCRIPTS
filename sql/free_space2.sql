column TABLESPACE_NAME format a30
column FILE_NAME format a60
set line 130
set pagesize 500
select a.tablespace_name, a.file_name, a.bytes/1048576 mb_size, sum(b.bytes/1048576) mb_free 
 from dba_data_files a, dba_free_space b
 where a.file_id=b.file_id
 group by a.tablespace_name, a.file_name, a.bytes/1048576
 order by tablespace_name, a.file_name
 /
