set pages 1000
set line 300
alter session set nls_date_format='MMDDYY-HH24MI';
select * from
  (select THREAD#, SEQUENCE#, FIRST_CHANGE#, FIRST_TIME, NEXT_CHANGE#, NEXT_TIME, 
          STANDBY_DEST, ARCHIVED, APPLIED, STATUS, COMPLETION_TIME 
   from v$archived_log 
--   where STANDBY_DEST='YES' 
   order by SEQUENCE# desc, THREAD#)
where rownum < 31;
