select username, machine, count(*) from v$session where type<>'BACKGROUND'
group by username, machine
/
