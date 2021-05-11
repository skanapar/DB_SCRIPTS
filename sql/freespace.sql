column FreePerct format 99.99
column totalMb format 9999999999.99
column freeMb format 9999999999.99
compute sum of totalMb on report
compute sum of freeMb on report
break on report
select 
 a.tablespace_name, 
 a.contents, 
 a.status, 
 totalMb, 
 freeMb,
 freeMb*100/totalMb FreePerct
from 
 dba_tablespaces a, 
 (select tablespace_name, sum(bytes)/1048576 totalMb from dba_data_files
   group by tablespace_name) b, 
 (select tablespace_name, sum(bytes)/1048576 freeMb from dba_free_space
   group by tablespace_name) c 
where 
 a.tablespace_name = b.tablespace_name(+)
 and a.tablespace_name = c.tablespace_name(+)
 and a.contents <> 'TEMPORARY'
union
select 
 d.tablespace_name, 
 d.contents, 
 d.status, 
 totalMb, 
 freeMb,
 freeMb*100/totalMb FreePerct
from 
 dba_tablespaces d, 
 (select tablespace_name, sum(bytes)/1048576 totalMb from dba_temp_files
   group by tablespace_name) e, 
 (select tablespace_name, free_space/1048576 freeMb from dba_temp_free_space) f 
where 
 d.tablespace_name = e.tablespace_name(+)
 and d.tablespace_name = f.tablespace_name(+)
 and d.contents = 'TEMPORARY'
order by
 tablespace_name
/
