undefine user_like
undefine machine_like
column PERMIT_MACHINE_PATTERN format a60
column user_pattern format a30
select * from ADMIN.RESTRICTED_USERS
  where user_pattern like '%'||decode('&&user_like', null, user_pattern, '&&user_like')||'%'
  and PERMIT_MACHINE_PATTERN like '%'||decode('&&machine_like', null, PERMIT_MACHINE_PATTERN, '&&machine_like')||'%'
/