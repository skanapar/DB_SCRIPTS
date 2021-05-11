set pagesize 999
column owner format a12
column category format a15
column name format a30
break on owner
select owner,category,name, used
from dba_outlines
order by 1, 2, 4, 3
/
