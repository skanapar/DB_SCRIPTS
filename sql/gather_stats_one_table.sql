begin

dbms_stats.gather_table_stats( 
ownname=> 'FINANCIALS', 
tabname=> 'SL_ACCOUNTING_EVENTS' , 
estimate_percent=> DBMS_STATS.AUTO_SAMPLE_SIZE, 
cascade=> DBMS_STATS.AUTO_CASCADE, 
degree=> null, 
no_invalidate=> DBMS_STATS.AUTO_INVALIDATE, 
granularity=> 'AUTO', 
method_opt=> 'FOR ALL COLUMNS SIZE AUTO');

end;
