set pagesize 1000
set linesize 132

column owner       heading "Owner"      format a10
column object_name heading "ObjectName" format a30
column object_id   heading "ObjectId"   format 99999999
column object_type heading "ObjectType" format a20
column created     heading "Created"    format a20
column status      heading "Status"     format a7

ttitle left "List of New Objects Created "  skip 2

spool /tmp/new_objects.lst
select owner,object_name,object_id,object_type,created,status
from dba_objects
where trunc(created) = trunc(sysdate)-1 and
object_name not in('CHECK_ENOUGH_SPACE') and
object_type != 'SEQUENCE'
;
spool off
exit;
