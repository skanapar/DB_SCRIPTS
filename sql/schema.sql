set linesize 200
set pagesize 200
col Datafile for a77
col Tblspc for a39
col MB for 9999
select t.name Tblspc, d.NAME Datafile,bytes/1024/1024 MB, status
from v$tablespace t, v$datafile d
where t.TS#=d.TS#
and t.NAME like upper('%&1%')
order by 1,2
/

