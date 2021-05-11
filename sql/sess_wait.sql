clear breaks
set lines 132
col event for a40
select event,sid,p1,p2,p3 from v$session_wait
where event not in ('SQL*Net message from client','SQL*Net message to client','rdbms ipc message','ges remote message','gcs remote message','pmon timer','smon timer')
;
select event,count(*) from v$session_wait
where event not in ('SQL*Net message from client','SQL*Net message to client','rdbms ipc message','ges remote message','gcs remote message','pmon timer','smon timer')
group by event;
