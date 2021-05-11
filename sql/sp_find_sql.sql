set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99

select /*+ FULL(stats$sql_summary) PARALLEL(stats$sql_summary,8) */
distinct s.address, s.hash_value, s.executions execs, s.elapsed_time/1000000 etime,
decode(s.executions,0,0,(s.elapsed_time/1000000)/s.executions) avg_etime, 
s.text_subset
from stats$sql_summary s
where hash_value in (select hash_value from stats$sqltext t
where t.sql_text like nvl('&sql_text',t.sql_text))
/

