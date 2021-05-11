set feed off lines 150 pages 200
col name   for a10
select d.name, inst_id, p.name, p.open_mode, p.restricted
from gv$pdbs p, v$database d
order by 3
/

