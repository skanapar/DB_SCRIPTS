set heading off
set feedback off
col name format a20
select d.db_unique_name, inst_id, p.name , p.open_mode, p.restricted
from gv$pdbs p, v$database d
order by 3

/
