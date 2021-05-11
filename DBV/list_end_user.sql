set lines 150
col username format a30
col acct_status format a12
col roles_granted  format a65
col profile  format a30
select username, profile, account_status acct_status, 
        (select listagg(granted_role, ',') within group
                  (order by granted_role) from dba_role_privs where grantee=username) Roles_granted,
        (select name from v$database) db_name
from dba_users
where oracle_maintained='N'
/
