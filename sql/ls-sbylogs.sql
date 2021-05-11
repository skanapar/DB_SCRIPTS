column member format a60
select a.thread#, a.group#, b.member, a.status, a.bytes/1048756 Mb
from v$standby_log a, v$logfile b
where a.group# = b.group#
order by a.thread#, a.group#
/
