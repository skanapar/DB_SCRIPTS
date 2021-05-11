--log_switches_daily.sql
--Gives a count and total GB of logswitches per day from the present date backwards
--based on the 'sysdate-x' clause

select a.DAY, a.DAYNAME, a.LOGSWITCHES,
round((sum(a.logswitches*b.bytes)/1024/1024/1024),1) "GB"
from
(select trunc(first_time) "DAY", 
to_char(trunc(first_time),'DD') "DAYNAME",
count(trunc(first_time)) "LOGSWITCHES"
from gv$loghist
where trunc(first_time) >= (sysdate-7)
group by trunc(first_time)) a,
(select bytes from v$log where rownum < 2) b
group by a.DAY, a.DAYNAME, a.LOGSWITCHES
order by a.DAY desc
/
