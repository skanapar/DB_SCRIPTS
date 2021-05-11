set lines 132
set pagesize 999
column external_name format a10
col username format a25
select username, user_id, account_status, default_tablespace
from dba_users
where username like nvl('&username',username)
and account_status like nvl('%&status%',account_status)
order by username
/

