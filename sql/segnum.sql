select owner, tablespace_name, count(*) from dba_segments
group by owner, tablespace_name
/
