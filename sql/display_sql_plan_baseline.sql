select * from TABLE(DBMS_XPLAN.display_sql_plan_baseline(sql_handle=>'&SQL_HANDLE'))
/
