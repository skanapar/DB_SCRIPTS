set pagesize 1000
set linesize 132
select 'exec dbms_system.set_sql_trace_in_session(' || sid || ',' || serial# || ',TRUE);'
from v$session
where sid = &sid;
