column file_name format a60
set pages 120
set line 120
break on tablespace_name nodup
select tablespace_name,file_id,file_name,bytes/1048576 mb from dba_temp_files order by tablespace_name;
