set head off
set feed off
spool renameredo.sql
select 'alter database rename file '''||member||''' to ''+DATAC1/&junk_inst./ONLINELOGS/'||substr(member,instr(member,'/',-1,1)+1,length(member))||''';' from v$logfile
/
spool off
set head on
set feed on
