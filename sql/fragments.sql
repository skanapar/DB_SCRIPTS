set pagesize 60
set linesize 120
set feedback off

column dbn new_value dbn_sp
select name as dbn from v$database;
spool fragm_&dbn_sp

prompt Checking for Fragmented Database Objects:
prompt
column Owner noprint new_value Owner_Var
column Segment_Name format a25 heading 'Object Name'
column Segment_Type format a9 heading 'Table/Index'
column Bytes format 999,999,999,999 heading 'Bytes Used'
column Extents format 999999 
column Tablespace_Name format a20 heading 'TS Name'
break on Owner skip page 2
ttitle center 'Table Fragmentation Report' skip 2 -
   left 'creator: ' Owner_Var skip 2

select owner, segment_name, segment_type, bytes,
       max_extents, extents, tablespace_name, initial_extent, next_extent
from dba_segments
where
extents > 10 and
segment_type = 'TABLE' 
and owner = 'TESTDTA'
-- and tablespace_name in('USERS')
order by owner, extents, segment_name, segment_type desc
/

ttitle center 'Index Fragmentation Report' skip 2 -
   left 'creator: ' Owner_Var skip 2

select owner, segment_name, segment_type, bytes,
       max_extents, extents, tablespace_name, initial_extent, next_extent
from dba_segments
where
extents > 10 and
segment_type = 'INDEX'
and owner = 'TESTDTA'
-- and tablespace_name in('USERS')
order by owner, extents, segment_name, segment_type desc
/

spool off
