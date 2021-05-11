set echo on feedback on term on 
spool $logfile
drop table temp_open_cursors;
create table temp_open_cursors as
        select
                decode(c.name,'GRAPRD','RankingDB','SPTPRD','Sports','STSPRD','Stats','Others') as dbName,
                sysdate as SnapTime, count(*) as sess, sum(value) as TotalOpenCursors
                from v$sesstat a, v$statname b, v$database c
                where a.STATISTIC# = b.STATISTIC#
                and b.name = 'opened cursors current' 
                group by c.name;
insert into Monitor_Open_Cursors
	select * from temp_open_cursors;
drop table temp_open_cursors;
spool off
exit

