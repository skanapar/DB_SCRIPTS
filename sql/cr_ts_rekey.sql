set head off
set feed off
spool  run-rekey_ts.sql
select 'alter tablespace '||tablespace_name||' encryption using ''AES256'' rekey;' from dba_tablespaces where contents <> 'TEMPORARY';
spool off
