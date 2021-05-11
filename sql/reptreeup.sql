spool reptreup
select lpad('|-> ',(level-1)*10,' ')||
empno||' '||fname||' '||mname||' '||lname ||
' ( '||job_code||': '||(select sprint_title from title where job_code=e.job_code)||' ) '||dept_code
from employee e
start with empno=&EmpnoStart
connect by prior spv_empno = empno
/
spool off