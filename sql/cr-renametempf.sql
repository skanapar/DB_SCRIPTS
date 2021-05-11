set head off
set feed off
spool renametempf.sql
select 'alter database rename file '''||name||''' to ''+DATAC1/&junk_inst./TEMPFILE/'||substr(name,instr(name,'/',-1,1)+1,length(name))||''';' from v$tempfile
/
spool off
set head on
set feed on
