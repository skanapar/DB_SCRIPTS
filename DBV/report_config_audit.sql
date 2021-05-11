set lines 160
col username format a20
col action_name FOR a30
col action_object_name FOR a20
ALTER SESSION SET nls_date_format="yyyy-mm-dd hh24:mi:ss";
SELECT username,TIMESTAMP,action_name,action_object_name FROM dvsys.dv$configuration_audit 
order by  timestamp
/
