select tablespace_name, owner, segment_name, segment_type, bytes/1048576 mb from dba_segments where owner=upper('&owner')
and tablespace_name=upper('&ts_name')
order by tablespace_name, segment_type
/
