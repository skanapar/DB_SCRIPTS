----------------------------------------------------------------------------------------
--
-- File name:   largest_100_objects.sql
--
-- Purpose:     Reports 100 largest objects as per segments bytes
--
-- Author:      Carlos Sierra
--
-- Version:     2013/12/17
--
-- Usage:       This script reads DBA_SEGMENTS and reports the Top 100 objects as per
--              size in bytes of their aggregate segments.
--              It includes sub-totals for Top 20 and Top 100 then a grant total
--              for all objects on DBA_SEGMENTS.
--
-- Example:     @largest_100_objects.sql
--
--  Notes:      Developed and tested on 11.2.0.3 
--             
---------------------------------------------------------------------------------------
--
SPO largest_100_objects.txt;
SET NEWP NONE PAGES 50 LINES 32767 TRIMS ON;

COL rank FOR 9999;
COL segment_type FOR A18;
COL segments FOR 999,999,999,999;
COL extents  FOR 999,999,999,999;
COL blocks   FOR 999,999,999,999;
COL bytes    FOR 999,999,999,999,999;
COL gb       FOR 999,999.000;
COL segments_perc FOR 990.000;
COL extents_perc  FOR 990.000;
COL blocks_perc   FOR 990.000;
COL bytes_perc    FOR 990.000;

WITH schema_object AS (
SELECT /*+ MATERIALIZE */
       segment_type,
       owner,
       segment_name,
       COUNT(*) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes
  FROM dba_segments
 GROUP BY
       segment_type,
       owner,
       segment_name
), totals AS (
SELECT /*+ MATERIALIZE */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes
  FROM schema_object
), top_100 AS (
SELECT /*+ MATERIALIZE */
       ROWNUM rank, v1.*
       FROM (
SELECT so.segment_type,
       so.owner,
       so.segment_name,
       so.segments,
       so.extents,
       so.blocks,
       so.bytes,
       ROUND((so.segments / t.segments) * 100, 3) segments_perc,
       ROUND((so.extents / t.extents) * 100, 3) extents_perc,
       ROUND((so.blocks / t.blocks) * 100, 3) blocks_perc,
       ROUND((so.bytes / t.bytes) * 100, 3) bytes_perc
  FROM schema_object so,
       totals t
 ORDER BY
       bytes_perc DESC NULLS LAST
) v1
 WHERE ROWNUM < 101
), top_100_totals AS (
SELECT /*+ MATERIALIZE */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_100
), top_20_totals AS (
SELECT /*+ MATERIALIZE */
       SUM(segments) segments,
       SUM(extents) extents,
       SUM(blocks) blocks,
       SUM(bytes) bytes,
       SUM(segments_perc) segments_perc,
       SUM(extents_perc) extents_perc,
       SUM(blocks_perc) blocks_perc,
       SUM(bytes_perc) bytes_perc
  FROM top_100
 WHERE rank < 21
)
SELECT v.rank,
       v.segment_type,
       v.owner,
       v.segment_name,
       CASE 
       WHEN v.segment_type LIKE 'INDEX%' THEN
         (SELECT i.table_name
            FROM dba_indexes i
           WHERE i.owner = v.owner AND i.index_name = v.segment_name)
       END table_name,
       v.segments,
       v.extents,
       v.blocks,
       v.bytes,
       ROUND(v.bytes / 1024 / 1024 / 1024, 3) gb,
       v.segments_perc,
       v.extents_perc,
       v.blocks_perc,
       v.bytes_perc
  FROM (
SELECT d.rank,
       d.segment_type,
       d.owner,
       d.segment_name,
       d.segments,
       d.extents,
       d.blocks,
       d.bytes,
       d.segments_perc,
       d.extents_perc,
       d.blocks_perc,
       d.bytes_perc
  FROM top_100 d
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
       NULL owner,
       'TOP  20' segment_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc
  FROM top_20_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       NULL segment_type,
       'TOP 100' owner,
       NULL segment_name,
       st.segments,
       st.extents,
       st.blocks,
       st.bytes,
       st.segments_perc,
       st.extents_perc,
       st.blocks_perc,
       st.bytes_perc
  FROM top_100_totals st
 UNION ALL
SELECT TO_NUMBER(NULL) rank,
       'TOTAL' segment_type,
       NULL owner,
       NULL segment_name,
       t.segments,
       t.extents,
       t.blocks,
       t.bytes,
       100 segemnts_perc,
       100 extents_perc,
       100 blocks_perc,
       100 bytes_perc
  FROM totals t) v;

SET NEWP 1 PAGES 14 LINES 80 TRIMS OFF;
SPO OFF; 
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
