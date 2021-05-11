select 
'exec DBMS_SPM.DROP_SQL_PLAN_BASELINE (sql_handle => '''||a.sql_handle||''', plan_name => '''||a.plan_name||''');'
--, b.cnt, a.created, a.accepted
from 
dba_sql_plan_baselines a,
(select sql_handle, count(*) cnt 
from dba_sql_plan_baselines group by sql_handle) b
where 
    a.SQL_HANDLE=b.sql_handle
    and b.cnt > 2
--    and a.created < sysdate-30
    and a.accepted = 'NO'
order by 
    b.cnt desc, a.sql_handle, a.created;
