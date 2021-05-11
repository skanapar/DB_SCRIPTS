SELECT sql_handle, dbms_lob.substr(sql_text,200,1), count(*)
FROM   dba_sql_plan_baselines
group by sql_handle, dbms_lob.substr(sql_text,200,1) 
order by count(*) desc;


describe dba_sql_plan_baselines