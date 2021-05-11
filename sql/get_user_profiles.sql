col name format a10
col username format a30
col profile format a35
  select username, profile, (select name from v$database) name
 from dba_users
   where oracle_maintained='N'
/

