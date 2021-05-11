accept task_name -
       prompt 'Task_Name: ' 
accept sql_id -
       prompt 'SQL_ID: ' 
accept time_limit -
       prompt 'Time_limit: ' 
DECLARE
 ret_val VARCHAR2(4000);
BEGIN
ret_val := dbms_sqltune.create_tuning_task(task_name=>'&&Task_name', sql_id=>'&&sql_id', time_limit=>&&time_limit);
dbms_sqltune.execute_tuning_task('&&Task_name');
END;
/
undef task_name
undef sql_id
undef time_limit
