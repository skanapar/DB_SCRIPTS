col sql_id for a14
col LOAD_T for a25
col ACTIVE_T for a25
col child_number for 999
col sql_fulltext for a30 word_wrap
select module,sql_id,child_number CN,plan_hash_value phv,
case (executions) when 0 then 0 else round(executions) end as executions,
case (executions) when 0 then 0 else round(elapsed_time/executions) end as elapsed_per_exe from v$sql
where sql_id in (select distinct sql_id from v$sql_plan where object_name='&object_name')
and module not in ('DBMS_SCHEDULER','SQL Developer','SQL*Plus') and sql_fulltext not like '%parallel%' order by 1,2,3;
