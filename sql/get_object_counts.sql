col name format a15
set lines 200
select name,object_type, count(*)
from v$pdbs, dba_objects
where owner(+)='SYSADM'
group by name, object_type
/
