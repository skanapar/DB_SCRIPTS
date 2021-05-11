rem This Program is used to find the number of active connection
rem and can page and email dba's 
rem Author : Saurabh  04/30/04

set heading off feedback off term off trimspool on pages 0
spool  /tmp/active_sess_alarm.lst
select rtrim(ltrim(count(1))) from v$session where 
status='ACTIVE' 
/
spool off
exit;
