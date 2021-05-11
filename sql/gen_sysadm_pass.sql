whenever sqlerror continue
set feed off head off long 1000000 longc 4000 pages 0 lines 4000 trims on ver off termo off
col ddl                 for a4000
col ddl2                for a4000

/***  enable SQLTERMINATOR ';' for dbms_metadata ***/
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true)


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




/***  Reset user passwords  **/

prompt /*************************************************************************************/
prompt /**************  Reset User passwords  ***********************************************/
prompt /*************************************************************************************/
prompt

with t as (select dbms_metadata.get_ddl('USER', username) ddl
  from dba_users
 where oracle_maintained = 'N'
   and common = 'NO'
and username='SYSADM'
 order by username)
select replace(substr(ddl,1,instr(ddl,'DEFAULT')-1), 'CREATE', 'ALTER') ||';' ddl2
  from t
/

