break on plan_hash_value skip 2
select hash_value, text_subset, count(distinct plan_hash_value) 
from stats$sql_plan_usage a, stats$snapshot b
where a.snap_id = b.snap_id
and text_subset like nvl('%'||'&sql_text'||'%',text_subset)
having count(distinct plan_hash_value) > 1
group by hash_value, text_subset
/
