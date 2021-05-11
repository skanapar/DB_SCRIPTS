set feedback off
set heading off
set long 1000000
set longchunksize 4000
set pagesize 0
set linesize 4000
set trimspool on
set verify off
set termout off

--def excl_user1="'APEX_040200','DBSNMP','PUBLIC','SYS','SYSADM','SYSTEM','WMSYS','XDB'"
def excl_user1="'APEX_040200','PUBLIC','SYS','SYSADM','SYSTEM','WMSYS','XDB'"
def excl_role1="'CONNECT','DBA','EXP_FULL_DATABASE','EXECUTE_CATALOG_ROLE','IMP_FULL_DATABASE','PUBLIC','RECOVERY_CATALOG_OWNER','RESOURCE','RSYSADM_ROLE','SELECT_CATALOG_ROLE','WM_ADMIN_ROLE','XDBADMIN'"

spool $DBC_SAVE_USERS_FILE

rem create users

--select
--  dbms_metadata.get_ddl('USER', username) ||';' text
--from dba_users
--where username not in (&&excl_user1)
--order by username;

select regexp_replace (
dbms_metadata.get_ddl('USER', username) ||';',
CHR(10) || CHR(32) || 'ALTER ', ';' || CHR(10) || CHR(32) || 'ALTER ' ) text
from dba_users
where username not in (&&excl_user1)
order by username;

rem create roles

select
  dbms_metadata.get_ddl('ROLE', role) ||';' text
from dba_roles
where role not in (&&excl_role1)
order by role;

rem system privs

select 'grant '||privilege||' to "'||grantee||'"'
    ||decode(admin_option, 'YES', ' with admin option')
    ||';'
from dba_sys_privs
where grantee not in (&&excl_user1
,&&excl_role1)
order by grantee, privilege;

rem role privs

select 'grant '||granted_role||' to "'||grantee||'"'
    ||decode(admin_option, 'YES', ' with admin option')
    ||';'
from dba_role_privs
where grantee not in (&&excl_user1
,&&excl_role1)
order by grantee, granted_role;

rem object privs (to users)

select 'grant '||privilege
    ||' on '||owner||'.'||table_name||' to "'||grantee||'"'
    ||decode(grantable, 'YES', ' with grant option')
    ||';'
from dba_tab_privs
where grantee not in (&&excl_user1
,&&excl_role1)
and 1=0
order by grantee, owner, table_name, privilege;

rem reset passwords

--select 'alter user "'||name||'" identified by values '''||spare4||''';' 
--from sys.user\$
--where spare4 is not null
--and name not in 'XS\$NULL'
--order by name;

select 'alter user "'||name||'" identified by values '''||spare4||''';'
from sys.user$
where spare4 is not null
and PASSWORD is null
and name not in 'XS$NULL'
order by name;

select 'alter user "'||name||'" identified by values '''||spare4|| ';' || password|| ''';'
from sys.user$
where spare4 is not null
and PASSWORD is not null
and name not in 'XS$NULL'
order by name;

spool off
