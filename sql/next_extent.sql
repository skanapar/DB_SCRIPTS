 select owner,segment_name, next_extent/1024/1024 "Next_Extent(MB)", s.tablespace_name,max_free_bytes
     from sys.dba_segments s,
         (select tablespace_name,max(bytes) max_free_bytes
            from sys.dba_free_space
           group by tablespace_name) f
   where s.next_extent > f.max_free_bytes
    and s.tablespace_name=f.tablespace_name
/
