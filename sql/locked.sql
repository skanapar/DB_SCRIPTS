select b.username, b.serial#, d.id1, a.sql_text
from v$session b, v$lock d, v$sqltext a
where b.lockwait = d.kaddr
and a.address = b.sql_address
and a.hash_value = b.sql_hash_value
/
