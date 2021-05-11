-- display the last 5 segment names for a specific file_id
set line 160
set pagesize 100
col owner format a18
col segment_name format a50
select *
  from (
select file_id, owner, segment_name,
       segment_type, block_id, tablespace_name
  from dba_extents
where file_id = &file_id
order by block_id desc
       )
where rownum <= 5;
