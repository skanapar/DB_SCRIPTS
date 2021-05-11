select a.sql_text
from v$session s, v$open_cursor o, v$sqlarea a
where
s.saddr=o.saddr and
s.sid=o.sid and
o.address=a.address and
o.hash_value=a.hash_value and
s.schemaname='RANKINGSERVER'
/
