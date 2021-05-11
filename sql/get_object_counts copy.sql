set linesize 120
col owner format a30
col object_type format a30
set pages 0
spool object_counts_&phase.log
select owner, object_type, count(9)
from dba_objects
group by owner, object_type
order by 1,2
/
spool off
