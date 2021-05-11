set echo off
set feedback off
set lines 200
set pagesize 35
set linesize 200 

col username for a23
set linesize 200

select distinct a.username, count(a.username) CNT, a.inst_id, b.instance_name,
--b.startup_time, b.status ,
a.failover_method, a.failover_type, a.failed_over
from gv$session a, gv$instance b 
where a.inst_id = b.inst_id 
and a.username is not null
and a.username not in ('SYS','SYSTEM')
group by a.username, a.inst_id, b.instance_name,b.startup_time, b.status,a.failover_method, a.failover_type, a.failed_over order by 
3 ;
