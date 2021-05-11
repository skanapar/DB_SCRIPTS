select distinct
a.sid "waiting sid"
, a.event
, c.sql_text "SQL from blocked session"
, b.sid "blocking sid"
, b.event
, b.sql_id
, b.prev_sql_id
, d.sql_text "SQL from blocking session"
from v$session a, v$session b, v$sql c, v$sql d
where a.event='enq: TX - row lock contention'
and a.blocking_session=b.sid
and c.sql_id=a.sql_id
and d.sql_id=nvl(b.sql_id,b.prev_sql_id)
/
