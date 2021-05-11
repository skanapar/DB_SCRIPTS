set lines 132
set pages 100
select segment_name,tablespace_name,initial_extent,next_extent,status from dba_rollback_segs
where INSTANCE_NUM = 4
/
