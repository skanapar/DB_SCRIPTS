select count(*) from v$session
where username not in ('SYS','SYSTEM')
/
