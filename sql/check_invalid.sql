select owner, count(9)
from dba_objects
where status <> 'VALID'
group by owner
/
