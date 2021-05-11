whenever sqlerror continue
set feed off head off long 1000000 longc 4000 pages 0 lines 4000 trims on ver off termo off
col ddl                 for a4000
col ddl2                for a4000

/***  enable SQLTERMINATOR ';' for dbms_metadata ***/
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true)


set termo off
col db_unique_name    new_value cdb
select db_unique_name
  from v$database
/
col con_name          new_value pdb
select sys_context('USERENV', 'CON_NAME') con_name
  from dual
/

/***  enable SQLTERMINATOR ';' for dbms_metadata ***/
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true)

spool ${SQL_DIR}/&&cdb._&&pdb._gen_ddl.sql
select ' whenever sqlerror continue'
from dual
/



/***  User DDL  ***/

prompt
prompt /*************************************************************************************/
prompt /**************  User DDL  ***********************************************************/
prompt /*************************************************************************************/
prompt

select dbms_metadata.get_ddl('USER', username) ddl
  from dba_users
 where oracle_maintained = 'N'
   and common = 'NO'
 order by username
/

/***  User Default Role  ***/

prompt /*************************************************************************************/
prompt /**************  User Default Role  **************************************************/
prompt /*************************************************************************************/
prompt

select dbms_metadata.get_granted_ddl('DEFAULT_ROLE', grantee) text
from
(select distinct drp.grantee
  from dba_role_privs drp
 where drp.default_role = 'YES'
   and exists (select du.username
                 from dba_users du
                where du.oracle_maintained = 'N'
                  and du.common = 'NO'
                  and drp.grantee = du.username
              )
 order by drp.grantee
)
/

/***  User Tablespace quota  ***/

prompt /*************************************************************************************/
prompt /**************  User Tablespace Quotas  *********************************************/
prompt /*************************************************************************************/
prompt

--select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', dtq.username) AS ddl
--  from dba_ts_quotas dtq
-- where exists (select du.username
--                 from dba_users du
--                where du.oracle_maintained = 'N'
--                  and du.common = 'NO'
--                  and dtq.username = du.username
--              )
-- order by dtq.username
select dbms_metadata.get_granted_ddl('TABLESPACE_QUOTA', username) AS ddl
from
(select distinct dtq.username
  from dba_ts_quotas dtq
 where exists (select du.username
                 from dba_users du
                where du.oracle_maintained = 'N'
                  and du.common = 'NO'
                  and dtq.username = du.username
              )
 order by dtq.username
)
/

/***  Role DDL  ***/

prompt /*************************************************************************************/
prompt /**************  Role DDL  ***********************************************************/
prompt /*************************************************************************************/
prompt

select dbms_metadata.get_ddl('ROLE', role) || ';' text
  from dba_roles
 where oracle_maintained = 'N'
   and common = 'NO'
 order by role
/

/***  Role privileges  ***/

prompt /*************************************************************************************/
prompt /**************  Role Privilege Grant  ***********************************************/
prompt /*************************************************************************************/
prompt

select dbms_metadata.get_granted_ddl('ROLE_GRANT', grantee) AS ddl
from
(select distinct drp.grantee
  from dba_role_privs drp
 where exists (select du.username
                 from dba_users du
                where du.oracle_maintained = 'N'
                  and du.common = 'NO'
                  and drp.grantee = du.username
              )
 order by drp.grantee
)
/

/***  System privileges  ***/

prompt /*************************************************************************************/
prompt /**************  System Privilege Grant  *********************************************/
prompt /*************************************************************************************/
prompt

select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', grantee) ddl
from
(select distinct grantee
  from dba_sys_privs dsp
 where exists (select du.username
                 from dba_users du
                where du.oracle_maintained = 'N'
                  and du.common = 'NO'
                  and dsp.grantee = du.username
              )
 order by dsp.grantee
)
/

/***  Object privileges  ***/

prompt /*************************************************************************************/
prompt /**************  Object Grant  *******************************************************/
prompt /*************************************************************************************/
prompt

select dbms_metadata.get_granted_ddl('OBJECT_GRANT', grantee) ddl
from
(select distinct grantee
  from dba_tab_privs dtp
 where exists (select du.username
                 from dba_users du
                where du.oracle_maintained = 'N'
                  and du.common = 'NO'
                  and dtp.grantee = du.username
              )
 order by dtp.grantee
)
/

/***  Reset user passwords  **/

prompt /*************************************************************************************/
prompt /**************  Reset User passwords  ***********************************************/
prompt /*************************************************************************************/
prompt

with t as (select dbms_metadata.get_ddl('USER', username) ddl
  from dba_users
 where oracle_maintained = 'N'
   and common = 'NO'
 order by username)
select replace(substr(ddl,1,instr(ddl,'DEFAULT')-1), 'CREATE', 'ALTER') ||';' ddl2
  from t
/

prompt /*************************************************************************************/
prompt /*************************************************************************************/
prompt /**************  Generate Profile DDL script in case they are missing  ***************
prompt

select dbms_metadata.get_ddl('PROFILE', profile) AS ddl
from
(select distinct profile
  from dba_users u
 where oracle_maintained = 'N'
   and common = 'NO'
   and u.profile <> 'DEFAULT'
 order by profile
)
/

prompt
prompt  **************  END of Profile Generation script  ***********************************/
prompt /*************************************************************************************/
prompt /*************************************************************************************/

spool off

