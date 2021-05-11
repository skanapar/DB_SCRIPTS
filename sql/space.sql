set echo off
set pagesize 1000
set linesize 200
col TABLESPACE_NAME for a60
col MB for 999999

select TABLESPACE_NAME, floor(sum(bytes/1024/1024)) MB
from dba_free_space
where TABLESPACE_NAME like upper('%&1%')
group by TABLESPACE_NAME
order by 2 desc
/

select TABLESPACE_NAME, FILE_ID , sum(BYTES_USED)/1024/1024 USEDMB , sum(bytes_free)/1024/1024 FREEMB from 
V$TEMP_SPACE_HEADER
group by TABLESPACE_NAME, FILE_ID
/
