
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
       sql_id      => '&&sql_id',
       scope       => DBMS_SQLTUNE.scope_comprehensive,
       time_limit  => 60,
       task_name   => 'tuning_task_&&sql_id'
);
DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/