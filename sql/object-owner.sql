set feedback off

prompt &1 - Object owner
prompt 
define object_owner = &1

prompt DB Objects:
prompt 
column object_name format a30
select owner, object_name, object_type, status, created from dba_objects where owner = upper('&&object_owner')
/
prompt 
prompt Dependencies:
prompt 
column referenced_name format a30
select owner, name, type, referenced_owner, referenced_name, referenced_type, dependency_type
  from dba_dependencies
  where owner = upper('&&object_owner')  
     or referenced_owner = upper('&&object_owner')
/
prompt 
prompt SQL Last 30 days:
prompt 
select sql_id, plan_hash_value, object_owner, object_name, object_type, timestamp
  from dba_hist_sql_plan
  where object_owner = upper('&&object_owner')
   and timestamp > sysdate - 30
/
prompt 
prompt Tuning Sets:
prompt 
select * from dba_sqlset where owner=upper('&&object_owner')
/

undefine object_owner
