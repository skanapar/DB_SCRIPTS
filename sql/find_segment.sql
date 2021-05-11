set head on
set lines 132
col segment_name for a30
col segment_type for a15
SELECT relative_fno, owner,
segment_name, segment_type
FROM dba_extents
WHERE file_id = &file
AND &block BETWEEN block_id AND
block_id + blocks - 1;
