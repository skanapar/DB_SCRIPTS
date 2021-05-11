col username for a30
set lines 132
set pages 132
select nvl(username,'BACKGROUND') username ,count(*) count from v$session group by username;
select * from v$license;
