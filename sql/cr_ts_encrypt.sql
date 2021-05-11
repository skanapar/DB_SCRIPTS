set head off
set feed off
spool  run-encr_ts-&pdb_name..sql
select 'alter tablespace '||tablespace_name||' encryption online using ''AES256'' encrypt;' from dba_tablespaces where contents <> 'TEMPORARY';
spool off
