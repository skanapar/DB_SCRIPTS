set head off
set feed off
select 'alter tablespace '||ts.tablespace_name||' add tempfile ''+DATAC1'' size 20G;'
from dba_tablespaces ts, v$tablespace vt
where
ts.tablespace_name = vt.name
and ts.contents = 'TEMPORARY'
/
set head on
set feed on
