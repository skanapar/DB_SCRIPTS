set verify on
set lines 132
set pages 100
col member for a70

select lf.member,l.bytes/1024/1024 MB,l.group#,l.sequence#,l.archived,l.status from v$Log l,v$logfile lf
where l.group#=lf.group# 
/

select name,value from v$sysstat
where (name like '%redo%'
or name like '%checkpoint%')
and value != 0
/ 

