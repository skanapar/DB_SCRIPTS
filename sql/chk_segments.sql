select owner "Owner", tablespace_name "Tablespace", 
   segment_name "Segment", extents "Extents", bytes/1024/1024 "Megabytes"
from sys.dba_segments 
where upper(substr(segment_name,1,4)) != 'BIN$'
and upper(substr(segment_name,1,3)) != 'DR$'
and (:TABLESPACE_NAME is null or 
   instr(lower(tablespace_name),lower(&TABLESPACE_NAME)) > 0)
order by bytes/1024/1024 desc, extents desc, tablespace_name, segment_name
/