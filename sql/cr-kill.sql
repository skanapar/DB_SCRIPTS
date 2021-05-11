set pages 0
spool tmp/kill.sql
select 'alter system kill session '''||sid||','||serial#||''' immediate;' from v$session where module like '&modlike%'
/
spool off
set pages 100