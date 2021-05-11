break on plan_hash_value skip 1
set lines 200
col optimizer for A9
select hash_value, snaptime, prev_plan_hash_value, prev_cost, prev_optimizer, plan_hash_value, cost, optimizer, text_subset
-- seq_no, row_number() over (partition by hash_value order by snap_id) seqno 
from 
(select a.hash_value, a.snap_id, snap_time snap_date, to_char(snap_time,'DD-MON-YY HH24:MI') snaptime, 
text_subset, plan_hash_value, cost, optimizer,
lag(to_char(snap_time,'DD-MON-YY HH24:MI') ,1,null) over (partition by a.hash_value order by a.snap_id) prev_snaptime,
lag(plan_hash_value,1,null) over (partition by a.hash_value order by a.snap_id) prev_plan_hash_value,
lag(cost,1,null) over (partition by a.hash_value order by a.snap_id) prev_cost,
lag(optimizer,1,null) over (partition by a.hash_value order by a.snap_id) prev_optimizer,
row_number() over (partition by a.hash_value order by a.snap_id) seq_no,
first_value(plan_hash_value) over (partition by a.hash_value order by a.snap_id) first_plan_hash_value
from stats$sql_plan_usage a, stats$snapshot b
where a.snap_id = b.snap_id)
where (prev_plan_hash_value != plan_hash_value or prev_cost != cost or prev_optimizer != optimizer)
-- and first_plan_hash_value != plan_hash_value
and hash_value = &hash_value
and snap_date > sysdate-nvl('&days',365)
/
