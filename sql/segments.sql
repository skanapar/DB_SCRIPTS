set pages 50
select owner, segment_type, tablespace_name,count(*) from dba_segments where
owner not in ('SYS','SYSTEM')
group by owner, segment_type, tablespace_name
/
