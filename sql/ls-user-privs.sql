undefine usr
select privilege from dba_sys_privs where grantee='&&usr'
/
select granted_role from dba_role_privs where grantee='&&usr'
/
select 'grant '||privilege||' on '||owner||','||table_name||' to &&usr;' tab_privs from dba_tab_privs where grantee='&&usr'
/
