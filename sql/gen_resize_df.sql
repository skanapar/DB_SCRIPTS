-- Generate resize statements to shrink as much as possible for all datafiles
select 'alter database datafile ''' ||
 file_name || ''' resize ' ||
ceil( (nvl(hwm,1)*block_size)/1024/1024 )
|| 'm;' cmd
from dba_data_files a, dba_tablespaces ts,
     ( select file_id,
         max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
  and a.tablespace_name=ts.tablespace_name
and a.tablespace_name='SYSAUX'
  and ceil(blocks*block_size/1024/1024)-
      ceil((nvl(hwm,1)*block_size)/1024/1024 ) > 0
 
