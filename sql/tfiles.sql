set verify off
set feedback off
set linesize 132
break on report on tablespace_name skip 1
compute sum of mb on tablespace_name
compute sum of mb on report
column file_name format a75
column mb format 99,99,999

select tablespace_name,file_name,bytes/1024/1024 mb from dba_temp_files
where tablespace_name like '%&tablespace_name%'
;
