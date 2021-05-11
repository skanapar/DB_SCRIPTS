column dbn new_value dbn_sp
select name as dbn from v$database;
spool newctrlogf_&dbn_sp.sql

column member format a70

select value from v$parameter where name='control_files';

select * from v$logfile;

select 'alter database add logfile group '||GROUP#||' member ''+DATAC4'';' from v$logfile where type='ONLINE';

spool off
