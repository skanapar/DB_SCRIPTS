set lines 120
set pages 9999
spool encrypt.sql
 select 'alter database datafile '||chr(39)||df.name||chr(39)||' encrypt;' COMMAND
   from v$tablespace ts, v$datafile df where ts.ts#=df.ts# and
     (ts.name not in ('SYSTEM','SYSAUX') and ts.name not in
     (select value from gv$parameter where name='undo_tablespace'));
spool off
