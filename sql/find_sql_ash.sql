set long 4000
set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a60
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

select sql_id, 
DBMS_LOB.SUBSTR(sql_text,4000,1) sqlt
from dba_hist_sqltext
where DBMS_LOB.SUBSTR(sql_text,4000,1) like nvl('&sql_text',DBMS_LOB.SUBSTR(sql_text,4000,1))
and DBMS_LOB.SUBSTR(sql_text,4000,1) not like '%from dba_hist_sqltext where sql_text like nvl(%'
and sql_id like nvl('&sql_id',sql_id)
/
