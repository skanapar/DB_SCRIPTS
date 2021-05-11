set pagesize 60
set linesize 120
set feedback off

column dbn new_value dbn_sp
select name as dbn from v$database;
spool tmp/part_fragm_&dbn_sp

prompt Checking for Fragmented Database Objects:
prompt
column Owner noprint new_value Owner_Var
column Segment_Name format a25 heading 'Object Name'
column Segment_Type format a9 heading 'Type'
column Bytes format 999,999,999,999 heading 'Bytes Used'
column Extents format 999999 heading 'No.'
column Tablespace_Name format a20 heading 'TS Name'
break on Owner skip page 2
ttitle center 'Partition Report' skip 2 -
   left 'Owner: ' Owner_Var skip 2
select owner, segment_name, segment_type, bytes,
       max_extents, extents, tablespace_name, initial_extent, next_extent
from dba_segments
where
--extents > 100 and
bytes > 1048576000 and
segment_type like '%PARTITION' and
owner = 'FINANCIALS' and
tablespace_name='USL_ACCT_EVENTS_IDX'
order by owner, segment_name, segment_type, max_extents
/

spool off