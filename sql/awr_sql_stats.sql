set verify off
set pagesize 999
col username format a13
col prog format a22
col sql_text format a41
col sid format 999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99
col avg_cpu  format 9,999,999.99
col cpu format 9,999,999
col avg_pio format 9,999,999.99
col pio format 9,999,999
col avg_lio format 9,999,999.99
col lio format 9,999,999

select address, sql_id, child_number, executions execs, 
elapsed_time/1000000 etime,
(elapsed_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_etime, 
cpu_time/1000000 cpu, 
(cpu_time/1000000)/decode(nvl(executions,0),0,1,executions) avg_cpu,
disk_reads, 
disk_reads/decode(nvl(executions,0),0,1,executions) avg_pio,
buffer_gets lio, 
buffer_gets/decode(nvl(executions,0),0,1,executions) avg_lio,
sql_text
from DBA_HIST_SQLSTAT s
where sql_text like nvl('&sql_text',sql_text)
and sql_text not like '%from v$sql where sql_text like nvl(%'
and address like nvl('&address',address)
and sql_id like nvl('&sql_id',sql_id)
/

