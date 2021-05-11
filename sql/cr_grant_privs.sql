undefine GRUSER
select 'grant '||privilege||' on '||owner||'.'||TABLE_NAME||' to &&GRUSER;'  from dba_tab_privs where grantee='&&GRUSER';
select 'grant '||privilege||' to &&GRUSER;'  from dba_sys_privs where grantee='&&GRUSER';
select 'grant '||granted_role||' to &&GRUSER;'  from dba_role_privs where grantee='&&GRUSER';
