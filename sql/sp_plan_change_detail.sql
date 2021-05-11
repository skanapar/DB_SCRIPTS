break on plan_hash_value skip 2
select a.snap_id, to_char(snap_time,'DD-MON-YY HH24:MI') snaptime, text_subset, plan_hash_value, cost, optimizer
from stats$sql_plan_usage a, stats$snapshot b
where a.hash_value = &hash_value
and a.snap_id = b.snap_id
and snap_time > sysdate-nvl('&days',365)
order by a.snap_id
/
