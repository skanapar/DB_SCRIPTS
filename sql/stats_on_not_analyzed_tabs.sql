-- sample code so the stats rerun would only target the missed tables...

select owner, trunc(last_analyzed), count(*) 
from dba_tables 
where owner like 'E5%' 
group by owner, trunc(last_analyzed);

begin
for c1rec in
	(select owner,table_name
	from dba_tables
	-- where owner = 'E5_DATABASE' and trunc(last_analyzed) < trunc(sysdate) - 1 
	-- where owner = 'E5_ERGOTIME'
	  and last_analyzed IS NULL
	order by 1)
loop
	begin
	dbms_output.put_line(
		'dbms_stats.gather_table_stats('''||c1rec.owner||''','''||
			c1rec.table_name||''',
			CASCADE =>True,
			ESTIMATE_PERCENT=>30,
			DEGREE=>4,
			method_opt=>''for all columns size 1'')'); 
	dbms_stats.gather_table_stats(
		c1rec.owner,c1rec.table_name,
		CASCADE =>True,
		ESTIMATE_PERCENT=>30,
		DEGREE=>4,
		method_opt=>'for all columns size 1'); 
	commit ; 
	exception when others then dbms_output.put_line(sqlerrm); 
	end; 
end loop; 
end ; 
/


begin
for c1rec in
	(select owner,table_name
	from dba_tables
	-- where owner = 'E5_DATABASE' and trunc(last_analyzed) < trunc(sysdate) - 1 
	-- where owner = 'E5_DATABASE'
	  and last_analyzed IS NULL
	order by 1)
loop
	begin
	dbms_output.put_line(
		'dbms_stats.gather_table_stats('''||c1rec.owner||''','''||
			c1rec.table_name||''',
			CASCADE =>True,
			ESTIMATE_PERCENT=>30,
			DEGREE=>4,
			method_opt=>''for all columns size 1'')');
	dbms_stats.gather_table_stats(c1rec.owner,c1rec.table_name,
		CASCADE =>True,ESTIMATE_PERCENT=>30,
		DEGREE=>4,
		method_opt=>'for all columns size 1'); 
	commit ; 
	exception when others then dbms_output.put_line(sqlerrm); 
	end; 
end loop; 
end; 
/
