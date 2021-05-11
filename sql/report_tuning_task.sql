SET LONG 10000;
SET PAGESIZE 1000
SET LINESIZE 155
col recommendations for a150
SELECT DBMS_SQLTUNE.report_tuning_task(task_name=>'&task_name', owner_name=>'&owner') AS recommendations FROM dual;
