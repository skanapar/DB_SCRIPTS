set lines 132
set pages 9999
col statements for 999,999
col percent_of_total for 999.99
select executions execs, count(*) statements, 
ROUND(RATIO_TO_REPORT(count(*)) OVER () * 100 ,2) PERCENT_OF_TOTAL
from v$sqlarea
group by executions
order by 1 desc
/
