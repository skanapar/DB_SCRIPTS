set feedback off
set head off
set line 200
set pages 1000
set trimout on
spool run-encr-ts.sql
select 'alter database datafile '||chr(39)||df.name||chr(39)||' encrypt;' COMMAND from v$tablespace ts, v$datafile df where ts.ts#=df.ts# and ts.con_id=df.con_id and (ts.name not in ('SYSTEM','SYSAUX') and ts.name not in (select value from gv$parameter where name='undo_tablespace'));
spool off
set feedback on

