select 'alter user '||username||' profile C##APP_SVC_NO_EXP_ACCT_PROFILE;'
from dba_users
where oracle_maintained='N'
and profile='DEFAULT'
/
