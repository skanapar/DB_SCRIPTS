set termout off
set pages 1000
set line 132
set feedback off
set long 1500
clear compute
break on user_id skip page dup on report
compute number label '# of tickets: ' of problem_id on user_id 
compute number label 'Total tickets: ' of problem_id on report 

spool output/open
select  a.user_id, a.open_date, a.problem_id, 
a.first_contact_id PERSON_SSN, b.client_name, 
a.problem_code STATUS, a.close_date, 
round(sysdate-open_date) "DAYS OPEN", a.description
from problems a, client b where user_id in 
(select user_id from member_of
where group_id like 'SP %')
and a.first_contact_id=b.client_number
and a.problem_code <> 'CLOSED'
order by a.user_id, a.open_date, a.problem_id
/
spool off
set termout on
set feedback on
exit
