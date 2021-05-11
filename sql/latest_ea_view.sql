create or replace view latest_ea
as select * from ea 
-- Latest manager and approved assessment
where (empno, ea_date) in
	(select empno, max(ea_date) 
		from ea
		where assess_type='MGR'
		and approved='Y'
		group by empno)
/
