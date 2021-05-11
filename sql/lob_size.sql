column Gb format 999,999.90
select l.table_name, sum(bytes/(1048576*1024)) Gb from dba_segments s, dba_lobs l where  s.segment_name=l.segment_name and l.owner=upper('&tab_owner') group by l.table_name;