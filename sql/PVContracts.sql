create or replace view pvcontracts as
select r.short_name id, s1.description name_planview, 
	t.last_name||', '||t.first_name||' '|| t.middle_name name_ctron,
	s2.description planview_bucket, 
	t.social_sec_number ctron_ssn, 
	t.start_date, t.end_date 
from resources@ip_ora1 r, structure@ip_ora1 s1, structure@ip_ora1 s2, tb_employees@ctron t
where s1.father_code = s2.structure_code
	and s1.structure_code = r.resource_code
	and t.employee_id = r.short_name
	and r.short_name like 'C%'
/
