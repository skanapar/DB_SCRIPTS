set heading off
set feedback off
col name format a8
select  distinct p.name
from gv$pdbs p
where restricted='YES'
/

