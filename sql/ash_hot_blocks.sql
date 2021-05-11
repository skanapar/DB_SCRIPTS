set verify off
set pages 9999
set lines 132
col event for a30
col p1 for a20
col p2 for a20
col p3 for a20
col times for 999,999,999
select * from (
select event, p1text||' '||p1 p1,p2text||' '||p2 p2, count(*) times
from dba_hist_active_sess_history
where event like nvl('&event','read by other session')
group by 
event, p1text,p1,p2text,p2
order by count(*) desc
)
where rownum < 20 
/
