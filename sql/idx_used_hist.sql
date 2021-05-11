select distinct sql_id from v$sql_plan where object_name='&object_name' and module not in ('DBMS_SCHEDULER','SQL Developer','SQL*Plus') and sql_fulltext not like '%parallel%'
union
select distinct sql_id from dba_hist_sql_plan where object_name='&object_name' and module not in ('DBMS_SCHEDULER','SQL Developer','SQL*Plus') and sql_fulltext not like '%parallel%'
/
