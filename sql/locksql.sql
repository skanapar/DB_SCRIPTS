set lines 132 pages 100
col sql_text for a50 wrap
select
distinct sa.sql_text,
d.sid,
d.status,
DECODE(c.request,0,'Holder ','Waiter ') "holder?",
c.type,
c.ctime
from v$locked_object a, dba_objects b, v$lock c, v$session d,v$sqlarea sa
where a.object_id=b.object_id
     and c.sid=a.session_id
     and c.sid=d.sid
     and sa.hash_value=decode(d.status,'ACTIVE',d.SQL_HASH_VALUE,d.PREV_HASH_VALUE)
     and c.type != 'TM'
     order by 2,3;
