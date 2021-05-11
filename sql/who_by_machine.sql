break on report
compute sum of count(*) on report
col machine format a60
set lines 132
select machine,count(*) from v$session
where 
--status='ACTIVE' and 
type !='BACKGROUND' 
-- and username = 'ACE_SERVICE_RW1'
group by machine;
select count(*),status from v$session
where type !='BACKGROUND'
group by status;
