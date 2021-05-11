set pages 2000
set termout off
set line 283
column name format a40
column sprint_mail format a50
column title format a50
column spv_name format a40
column bu_name format a40
column tree_level format a10
spool reptree2.txt
select lpad(' ',level+1,'*') tree_level, e.ssn, e.fname||' '||e.mname||' '||e.lname name, 
e.sprint_mail, e.job_code,
(select sprint_title from title where job_code=e.job_code) title, 
e.mail_stop, e.bu_code, 
(select bu_name from bu where bu_code=e.bu_code) bu_name,
(select s.fname||' '||s.mname||' '||s.lname from employee s where empno=e.spv_empno) spv_name
from employee e
where emp_stat<>'T'
and org_code = 'PNT'
start with empno=6159
connect by prior empno = spv_empno
/
spool off
set termout on
set line 120
set pages 100
