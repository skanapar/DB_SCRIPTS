set verify off
select
   owner,
   segment_name,
   segment_type
from
   dba_extents
where
   file_id = &P1_file_id
and
  &P2_block_id between block_id and block_id + blocks -1;
