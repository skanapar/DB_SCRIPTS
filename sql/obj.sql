set verify off
set pagesize 999
col object_name format a30
col owner format a15
select owner, object_name, object_type, status, temporary temp
from dba_objects
where owner like nvl('&owner',owner)
and object_name like nvl('&name',object_name)
and object_type like nvl('&type',object_type)
/

