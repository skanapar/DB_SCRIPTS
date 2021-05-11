select distinct
a.sid "waiting sid"
, d.sql_text "waiting SQL"
, a.ROW_WAIT_OBJ# "locked object"
, a.BLOCKING_SESSION "blocking sid"
, c.sql_text "SQL from blocking session"
from v$session a, v$active_session_history b, v$sql c, v$sql d
where a.event='enq: TX - row lock contention'
and a.sql_id=d.sql_id
and a.blocking_session=b.session_id
and c.sql_id=b.sql_id
and b.CURRENT_OBJ#=a.ROW_WAIT_OBJ#
and b.CURRENT_FILE#= a.ROW_WAIT_FILE#
and b.CURRENT_BLOCK#= a.ROW_WAIT_BLOCK#
/
