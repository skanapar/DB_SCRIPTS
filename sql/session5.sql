set pagesize 999
set verify off
column sid format 999999
column username format a15
column cpu format 999,999.9
column elapsed format 999,999.9
column optimizer_mode format a15
select s.sid sid,
       s.serial# serial#,
       s.username username,
       p.program
  from v$session s, v$process p
 where
   p.addr = s.paddr
   and p.spid = nvl('&os_pid',p.spid)
/
