select  owner,segment_type,tablespace_name, count(*) from dba_segments
group by owner,segment_type, tablespace_name
order by owner, segment_type, tablespace_name
/
