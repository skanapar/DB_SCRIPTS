select granted_role from dba_role_privs where grantee='&&user';
select privilege from dba_sys_privs where grantee='&user';
select privilege||' on '||owner||'.'||table_name from dba_tab_privs where grantee='&user';
undefine user
