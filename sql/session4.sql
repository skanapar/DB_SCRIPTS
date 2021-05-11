set lines 140
set pagesize 999
set verify off
column sid format 999999
column username format a15
column sid_Ser# format a12
column cpu format 999,999.9
column elapsed format 999,999.9
column avg_elapsed format 999,999.9
select
       s.username username,
       '('||to_char(s.sid)||'.'||to_char(s.serial#)||')' sid_ser#,
       executions,
       elapsed_time/1000000 elapsed,
       round((elapsed_time/1000000)/nvl(executions,1),4) avg_elapsed,
       a.sql_id,
plan_hash_value,
       sql_text
  from v$sqlarea a, v$session s, v$process p
 where s.sql_hash_value = a.hash_value
   and s.sql_address    = a.address
   and s.username is not null
and p.addr = s.paddr
and p.spid = nvl('&os_pid',p.spid)
/

