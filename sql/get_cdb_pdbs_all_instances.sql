set heading off
set feedback off
col name format a20
select d.name, p.name , p.open_mode, p.restricted
from gv$pdbs p, v$database d
/
