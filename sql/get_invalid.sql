set linesize 120
col owner format a30
col object_name format a40
col object_type format a30
set pagesize 200 
spool invalid_objects.log
select owner, object_name, object_type
from dba_objects
where status <>'VALID'
/
spool off
