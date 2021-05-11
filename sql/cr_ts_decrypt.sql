set head off
set feed off
spool  run-decr_ts.sql
select 'alter tablespace '||tablespace_name||' encryption online decrypt;' from dba_tablespaces where contents <> 'TEMPORARY';
spool off
