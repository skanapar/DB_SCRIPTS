col days format 999.99
select instance_name,
to_char(startup_time,'DD-MON-YYYY HH24:MI') startup_time ,
to_char(sysdate,'DD-MON-YYYY HH24:MI') current_time ,
sysdate-startup_time days,
(sysdate-startup_time)*(24*60*60) seconds
from v$instance;

