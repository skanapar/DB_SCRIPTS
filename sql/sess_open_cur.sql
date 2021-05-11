select s.username, s.sid, sn.name, ss.value
from v$session s, v$sesstat ss, v$statname sn
where s.sid = ss.sid
and ss.statistic# = sn.statistic#
and ss.statistic# = 3
and s.username = 'RANKINGSERVER'
order by ss.sid desc
/
