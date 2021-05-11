select segment_name, segment_type, bytes/1048576 mb from dba_segments
where bytes > (1048576*1024) -- bigger than 1M
and segment_type='TABLE'
order by bytes desc
/

