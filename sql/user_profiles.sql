select USERNAME,nvl(PROFILE,'DEFAULT') profile_assigned,ACCOUNT_STATUS
from dba_users
where ORACLE_MAINTAINED='N'
order by 1
/
