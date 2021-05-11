create or replace view pv2tear as 
select r.short_name empno,
decode(tr.type,'A',a2.description,'S',
	decode(a.structure_code,'88','004',
                        '89','007',
                        '90','003',
                        '91','002',
                        '92','001',
                        '29586','005',
                        '14584','006',
                        '25136','111',
                        '94','012',
                        '95','011',
                        '96','009',
                        '97','008',
                        '616','010',
                        '99','013',
                        '14586','015',a.structure_code)
,'000') activity,
u.period_start start_date, u.period_finish end_date,
tr.slice1/60 day1,
tr.slice2/60 day2,
tr.slice3/60 day3,
tr.slice4/60 day4,
tr.slice5/60 day5,
tr.slice6/60 day6,
tr.slice7/60 day7,
tr.reported/60 total,
tr.signed_by signer, tr.signed_on signed_date, tr.approved_by approver, tr.approved_on approved_date,
decode(tr.integrate_status,'P','S',
                           'R','A',
                           'I','A',tr.integrate_status) status, 0 spv_empno 
from resources@ip_ora1 r, structure@ip_ora1 a,structure@ip_ora1 a2, user_period@ip_ora1 u, time_reported@ip_ora1 tr
where tr.resource_code = r.resource_code
and tr.code5 = a2.structure_code(+)
and tr.activity_code = a.structure_code
and tr.period_number = u.period_number@ip_ora1 
/
