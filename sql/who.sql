column machine format a10
column username format a10
column osuser format a10
column program format a30
set line 150
select s.username, status, machine, sid, s.serial#, spid, osuser, s.program from v$session s, v$process p
where s.paddr = p.addr
and s.username is not null
--and s.status='ACTIVE'
--and s.username='ITCM'
order by s.username
/
