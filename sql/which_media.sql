prompt If there is no rows means there is no backups.
prompt Also if TAG is null means it may be archive log backups
prompt
accept dbname char prompt 'Enter Database Name            : '
accept mnth   char prompt 'Enter Backup Date [DD-MON-YY]  : '
break on db_name on start_time on completion_time on tag
col tag format a20
col media format a10
set linesize 100
select distinct b.db_name,a.tag,trunc(a.start_time) start_time,
trunc(a.completion_time) completion_time,a.media,a.status "Status"
from bp a,dbinc b
where a.db_key = b.db_key and
b.db_name = upper('&dbname')  and
trunc(a.start_time) =  '&mnth'
order by trunc(a.start_time),a.tag,a.media;
