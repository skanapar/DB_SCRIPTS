select a.sql_handle,cnt "Count of Plans", created, last_modified, last_executed,optimizer_cost "Opt Cost", creator, accepted, enabled, fixed, autopurge, module, action
from dba_sql_plan_baselines a,
(SELECT sql_handle, count(*) cnt
FROM   dba_sql_plan_baselines
group by sql_handle) b
where A.SQL_HANDLE=b.sql_handle
and b.cnt > 3
order by cnt desc, sql_handle, created;


desc dba_sql_plan_baselines