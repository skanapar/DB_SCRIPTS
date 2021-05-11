
ttitle center "Tablespace Utlization Size in MB" skip 2

column tablespace_name  heading "TableSpace" format a30
column total_space      heading "TotalSpace" format 999999
column free_space       heading "FreeSpace"  format 999999
column used             heading "UsedSpace"  format 999999
column pct              heading "Used %"     format 999.99


set linesize 70
set pagesize 100
set verify on
set feedback on

break on report
compute sum of total_space on report
compute sum of free_space on  report
compute sum of used on report

select a.tablespace_name,total_space,free_space,
(total_space-free_space) used,
((total_space-free_space)/total_space)*100 pct
from
(select tablespace_name,sum(bytes)/(1024*1024) total_space
 from   dba_data_files
 group by tablespace_name) a,
(select tablespace_name,sum(Bytes)/(1024*1024) free_space
 from  dba_free_space
 group by tablespace_name) b
where a.tablespace_name = b.tablespace_name(+) and
((total_space-free_space)/total_space)*100 >85 and
free_space <2000 and
a.tablespace_name not in ('TEMP','RBS','PATROL')
order by 5 desc
/
