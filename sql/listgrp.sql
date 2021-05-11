set lines 132
set pages 100
col member for a40
select a.thread#,a.group#,b.member,a.status,a.bytes/1024/1024 MB
from v$log a,v$logfile b
where a.group# = b.group#
and thread# = 1;
