select USERNAME, program, count(*)
from admin.db_logons
where logon_time > sysdate-&days_ago
 and username like upper('%&user_like%')
group by USERNAME, program
order by username, program
/