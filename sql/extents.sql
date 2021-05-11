select owner, tablespace_name, segment_name, segment_type, bytes/1024 Kbytes, count(*) from dba_extents
where owner not in ('SYS','SYSTEM')
group by owner, tablespace_name, segment_name, segment_type, bytes
/
