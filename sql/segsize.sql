prompt &1 - Object owner
prompt 
define object_owner = &1

prompt &2 - Segment name
prompt 
define seg_name = &2

prompt &3 - TS name
prompt 
define ts_name = &3

compute sum of mb on report
break on report
column segment_name format a25
column tablespace_name format a20
column partition_name format a20
set line 140

select segment_name, segment_type, partition_name, bytes/1048576 Mb, extents, tablespace_name, INITIAL_EXTENT, NEXT_EXTENT
from dba_segments
where owner=decode(upper('&&object_owner'),'ALL',owner,upper('&&object_owner'))
and segment_name = decode(upper('&&seg_name'),'ALL',segment_name,upper('&&seg_name'))
and tablespace_name = decode(upper('&&ts_name'),'ALL',tablespace_name,upper('&&ts_name'))
order by mb, segment_name asc
/
