drop view user_cursors;
create view user_cursors as
 select 
ss.username||'('||se.sid||') ' user_process, sum(decode(name,'recursive calls',value)) "Recursive Calls", 
sum(decode(name,'opened cursors cumulative',value)) "Opened Cursors", sum(decode(name,'opened
cursors current',value)) "Current Cursors"
	from v$session ss, v$sesstat se, v$statname sn
 where  se.statistic# = sn.statistic#
		and (     name  like '%opened cursors current%'
				OR name  like '%recursive calls%'
				OR name  like '%opened cursors cumulative%')
		and  se.sid = ss.sid
		and	ss.username is not null
group by ss.username||'('||se.sid||') ';

ttitle 'Per Session Current Cursor Usage '
column USER_PROCESS format a25;
column "Recursive Calls" format 999,999,999;
column "Opened Cursors"  format 99,999; 
column "Current Cursors"  format 99,999;

select * from user_cursors   
 order by "Recursive Calls" desc; 
