create or replace view pipeline as
select to_char(pp.empno) emp_id, pp.tsc, 
	pp.mpc, pp.skill_group 
	primary_cfe,
	pp.start_date job_start, 
	pp.end_date job_end,
	nvl(s.unix,0) unix,
	nvl(s.nos,0) nos,
	nvl(s.database,0) database,
	nvl(s.security,0) security,
	nvl(s.desktop,0) desktop,
	nvl(s.web,0) web,
	nvl(s.network,0) network,
	nvl(s.proj_mgmt,0) proj_mgmt,
	nvl(sum(b.time),0) time
from skills s, billed b,
	(select e.empno, (e.lname||', '||e.fname) tsc ,
		(ee.empno||' '||ee.lname||', '||ee.fname) mpc,
		c.skill_group, a.start_date, a.end_date
	from employee e, employee ee, cfe c,
		(select empno, max(start_date) start_date,
			max(end_date) end_date
		from allocations
		group by empno) a
	where e.term_d is null
		and e.spv_empno=ee.empno
		and e.cfe_code=c.cfe_code
		and e.empno=a.empno
		and e.job_code in ('PT100','PT101','PT102')) pp
where pp.empno=s.empno(+)
	and pp.empno=b.empno(+)
group by pp.empno, pp.tsc, pp.mpc, pp.skill_group, pp.start_date,
	pp.end_date, s.unix, s.nos, s.database, s.security,
	s.desktop, s.web, s.network, s.proj_mgmt
/
