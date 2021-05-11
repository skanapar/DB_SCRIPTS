set pages 100
set lines 132
col event for a40
select event,p1,p2,p3,count(*) from v$session_wait
where event not like '%SQL*Net%'
and event not like '%timer%'
and event not like '%idle%'
and event not like '%Idle%'
and event not like '%PX Deq%'
and event not like '%rdbms ipc%'
and event not like '%Null event%'
and event not like '%file open%'
and event not like '%PX Idle Wait%'
and event not like '%timer%'
and event not like 'gcs remote message'
and event not like 'log file sync'
and event not like 'ges remote message'
group by event,p1,p2,p3
/
