col name format a20
col value format a20
select d.name, p.name, p.value
from v$parameter p, v$database d
where upper(p.name) like  'SGA%'
/
