set pages 999
set lines 132
select * from (
select sql_id, count(*), max(child_number), sql_text
from v$sql
group by sql_id, sql_text
having count(*) > 10
)
/

