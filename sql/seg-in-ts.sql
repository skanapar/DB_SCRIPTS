column segment format a40
column segment_type format a40
column mb format 999,999,990.00
select owner||'.'||segment_name as segment, segment_type, sum(bytes)/1048576 mb 
from dba_segments 
where tablespace_name like '%'||upper('&TS')
group by owner, segment_name, segment_type
order by segment_type, segment
/
