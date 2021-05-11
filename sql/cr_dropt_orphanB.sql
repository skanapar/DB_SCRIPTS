select 'drop table land.'||table_name||';' from dba_constraints where r_constraint_name in
(select constraint_name from dba_constraints
	where table_name in
	(select table_name from dba_tables
		where table_name in (select table_name from dba_tables where table_name like 'S%' or table_name like 'F%')
		and (table_name, owner) not in (select table_name, owner from sde.layers)
		and owner='LAND')
	and constraint_type='P')
and owner='LAND'
/
