SELECT * FROM
table(dbms_xplan.display_awr(sql_id=>nvl('&sql_id','atrnd612k84mz'),plan_hash_value=>nvl('&plan_hash_value',null),format=>'typical +peeked_binds'))
/
