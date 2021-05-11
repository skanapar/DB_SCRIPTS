----------------------------------------------------------------------------------------
--
-- File name:   planx.sql
--
-- Purpose:     Reports Execution Plans for one SQL_ID from RAC and AWR(opt)
--
-- Author:      Carlos Sierra
--
-- Version:     2013/12/18
--
-- Usage:       This script inputs two parameters. Parameter 1 is a flag to specify if
--              your database is licensed to use the Oracle Diagnostics Pack or not.
--              Parameter 2 specifies the SQL_ID for which you want to report all
--              execution plans from all nodes, plus all plans from AWR.
--              If you don't have the Oracle Diagnostics Pack license, or if you want
--              to omit the AWR portion then specify "N" on Parameter 1.
--
-- Example:     @planx.sql Y f995z9antmhxn
--
--  Notes:      Developed and tested on 11.2.0.3 and 12.0.1.0
--              For a more robust tool use SQLHC or SQLTXPLAIN(SQLT) from MOS
--             
---------------------------------------------------------------------------------------
--
CL COL;
SET FEED OFF VER OFF HEA ON LIN 2000 PAGES 50 TIMI OFF LONG 40000 LONGC 200 TRIMS ON AUTOT OFF;
PRO
PRO 1. Enter Oracle Diagnostics Pack License Flag [ Y | N ] (required)
DEF input_license = '&1';
PRO
PRO 2. Enter SQL_ID (required)
DEF sql_id = '&2';
-- set license
VAR license CHAR(1);
BEGIN
  SELECT UPPER(SUBSTR(TRIM('&input_license.'), 1, 1)) INTO :license FROM DUAL;
END;
/
-- get dbid
VAR dbid NUMBER;
BEGIN
  SELECT dbid INTO :dbid FROM v$database;
END;
/
-- spool and sql_text
SPO planx_&&sql_id..txt;
PRO SQL_ID: &&sql_id.
SET PAGES 0;
SELECT sql_fulltext FROM gv$sqlstats WHERE sql_id = '&&sql_id.' AND ROWNUM = 1;
SET PAGES 50000;
-- columns format
COL is_shareable FOR A12;
COL loaded FOR A6;
COL executions FOR A20;
COL rows_processed FOR A20;
COL buffer_gets FOR A20;
COL disk_reads FOR A20;
COL direct_writes FOR A20;
COL elsapsed_secs FOR A18;
COL cpu_secs FOR A18;
COL user_io_wait_secs FOR A18;
COL cluster_wait_secs FOR A18;
COL appl_wait_secs FOR A18;
COL conc_wait_secs FOR A18;
COL plsql_exec_secs FOR A18;
COL java_exec_secs FOR A18;
COL io_cell_offload_eligible_bytes FOR A30;
COL io_interconnect_bytes FOR A30;
COL io_saved FOR A8;
PRO
PRO GV$SQLSTATS (ordered by inst_id)
PRO ~~~~~~~~~~~
SELECT inst_id, 
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
  FROM gv$sqlstats
 WHERE sql_id = '&&sql_id.'
 ORDER BY 1;
PRO
PRO GV$SQLSTATS_PLAN_HASH (ordered by inst_id and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~
SELECT inst_id, plan_hash_value,
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
  FROM gv$sqlstats_plan_hash
 WHERE sql_id = '&&sql_id.'
 ORDER BY 1, 2;
PRO
PRO GV$SQL (ordered by inst_id and child_number)
PRO ~~~~~~
SELECT inst_id, child_number, plan_hash_value, is_shareable, 
       DECODE(loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
  FROM gv$sql
 WHERE sql_id = '&&sql_id.'
 ORDER BY 1, 2;
PRO       
PRO GV$SQL_PLAN_STATISTICS_ALL LAST (ordered by inst_id and child_number)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COL inst_child FOR A21;
BREAK ON inst_child SKIP 2;
SET PAGES 0;
WITH v AS (
SELECT /*+ MATERIALIZE */
       sql_id, inst_id, child_number
  FROM gv$sql
 WHERE sql_id = '&&sql_id.'
   AND loaded_versions > 0
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */
       RPAD('Inst: '||v.inst_id, 9)||' '||RPAD('Child: '||v.child_number, 11) inst_child, 
       t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY('gv$sql_plan_statistics_all', NULL, 'ADVANCED ALLSTATS LAST', 
       'inst_id = '||v.inst_id||' AND sql_id = '''||v.sql_id||''' AND child_number = '||v.child_number)) t;
SET PAGES 50000;
PRO
PRO DBA_HIST_SQLSTAT DELTA (ordered by snap_id DESC, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SELECT s.snap_id, 
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       s.instance_number, h.plan_hash_value,
       DECODE(h.loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(h.executions_delta, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(h.rows_processed_delta, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(h.buffer_gets_delta, '999,999,999,999,990'), 20) buffer_gets, 
       LPAD(TO_CHAR(h.disk_reads_delta, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(h.direct_writes_delta, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(h.elapsed_time_delta/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(h.cpu_time_delta/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(h.iowait_delta/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(h.clwait_delta/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(h.apwait_delta/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(h.ccwait_delta/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(h.plsexec_time_delta/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(h.javexec_time_delta/1e6, 3), '999,999,990.000'), 18) java_exec_secs,
       LPAD(TO_CHAR(h.io_offload_elig_bytes_delta, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(h.io_interconnect_bytes_delta, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN h.io_offload_elig_bytes_delta > h.io_interconnect_bytes_delta THEN
           LPAD(TO_CHAR(ROUND(
           (h.io_offload_elig_bytes_delta - h.io_interconnect_bytes_delta) * 100 / h.io_offload_elig_bytes_delta
           , 2), '990.00')||' %', 8) END io_saved
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = '&&sql_id.'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY 1 DESC, 4, 5;
PRO
PRO DBA_HIST_SQLSTAT TOTAL (ordered by snap_id DESC, instance_number and plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~~~~~~
SELECT s.snap_id, 
       TO_CHAR(s.begin_interval_time, 'YYYY-MM-DD HH24:MI:SS') begin_interval_time,
       TO_CHAR(s.end_interval_time, 'YYYY-MM-DD HH24:MI:SS') end_interval_time,
       s.instance_number, h.plan_hash_value,
       DECODE(h.loaded_versions, 1, 'Y', 'N') loaded, 
       LPAD(TO_CHAR(h.executions_total, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(h.rows_processed_total, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(h.buffer_gets_total, '999,999,999,999,990'), 20) buffer_gets, 
       LPAD(TO_CHAR(h.disk_reads_total, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(h.direct_writes_total, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(h.elapsed_time_total/1e6, 3), '999,999,990.000'), 18) elsapsed_secs,
       LPAD(TO_CHAR(ROUND(h.cpu_time_total/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(h.iowait_total/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(h.clwait_total/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(h.apwait_total/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(h.ccwait_total/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(h.plsexec_time_total/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(h.javexec_time_total/1e6, 3), '999,999,990.000'), 18) java_exec_secs,
       LPAD(TO_CHAR(h.io_offload_elig_bytes_total, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(h.io_interconnect_bytes_total, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN h.io_offload_elig_bytes_total > h.io_interconnect_bytes_total THEN
           LPAD(TO_CHAR(ROUND(
           (h.io_offload_elig_bytes_total - h.io_interconnect_bytes_total) * 100 / h.io_offload_elig_bytes_total
           , 2), '990.00')||' %', 8) END io_saved
  FROM dba_hist_sqlstat h,
       dba_hist_snapshot s
 WHERE :license = 'Y'
   AND h.dbid = :dbid
   AND h.sql_id = '&&sql_id.'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 ORDER BY 1 DESC, 4, 5;
PRO
PRO DBA_HIST_SQL_PLAN (ordered by plan_hash_value)
PRO ~~~~~~~~~~~~~~~~~
SET PAGES 0;
WITH v AS (
SELECT /*+ MATERIALIZE */ DISTINCT 
       sql_id, plan_hash_value, dbid
  FROM dba_hist_sql_plan 
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
 ORDER BY 1, 2, 3 )
SELECT /*+ ORDERED USE_NL(t) */ t.plan_table_output
  FROM v, TABLE(DBMS_XPLAN.DISPLAY_AWR(v.sql_id, v.plan_hash_value, v.dbid, 'ADVANCED')) t;
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (rollup by session_state, wait_class and event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET PAGES 50000;
COL samples FOR 999,999,999,999,999
COL state FOR A7;
COL wait_class FOR A14;
COL event FOR A40;
COL total FOR A17;
SELECT --GROUPING(session_state), GROUPING(wait_class), GROUPING(event),
       COUNT(*) samples,
       CASE 
       WHEN GROUPING(session_state) = 1 THEN 'Total'
       WHEN GROUPING(wait_class) = 1 THEN '  Sub Total'
       WHEN GROUPING(event) = 1 THEN '    Sub Sub Total'
       END total,
       session_state state, wait_class, event
  FROM dba_hist_active_sess_history
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
 GROUP BY
       ROLLUP(session_state, wait_class, event)
HAVING session_state = 'WAITING'
    OR GROUPING(wait_class) = 1;
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (group by operation, session_state, wait_class and event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COL operation FOR A40;
COL event FOR A60;
SELECT COUNT(*) samples,
       SUBSTR(sql_plan_operation||' '||sql_plan_options, 1, 40) operation,
       session_state||' '||wait_class||' '||
       CASE WHEN event IS NOT NULL THEN '"'||event||'"' END event
  FROM dba_hist_active_sess_history
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
 GROUP BY
       sql_plan_operation,
       sql_plan_options,
       session_state, 
       wait_class, 
       event
 ORDER BY
       sql_plan_operation,
       sql_plan_options,
       session_state, 
       wait_class, 
       event;
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY (group by phv, id, operation, session_state, wait_class and event)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
COL id FOR 9999;
SELECT COUNT(*) samples,
       sql_plan_hash_value plan_hash_value,
       sql_plan_line_id id,
       SUBSTR(sql_plan_operation||' '||sql_plan_options, 1, 40) operation,
       session_state||' '||wait_class||' '||
       CASE WHEN event IS NOT NULL THEN '"'||event||'"' END event
  FROM dba_hist_active_sess_history
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
 GROUP BY
       sql_plan_hash_value,
       sql_plan_line_id,
       sql_plan_operation,
       sql_plan_options,
       session_state, 
       wait_class, 
       event
 ORDER BY
       sql_plan_hash_value,
       sql_plan_line_id,
       sql_plan_operation,
       sql_plan_options,
       session_state, 
       wait_class, 
       event;
PRO
PRO DBA_HIST_ACTIVE_SESS_HISTORY I/O waits (group by phv, id, operation, wait_class, event and obj#)
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT COUNT(*) samples,
       sql_plan_hash_value plan_hash_value,
       sql_plan_line_id id,
       SUBSTR(sql_plan_operation||' '||sql_plan_options, 1, 40) operation,
       SUBSTR(wait_class||' '||
       CASE WHEN event IS NOT NULL THEN '"'||event||'"' END, 1, 60) event,
       current_obj#
  FROM dba_hist_active_sess_history
 WHERE :license = 'Y'
   AND dbid = :dbid 
   AND sql_id = '&&sql_id.'
   AND session_state = 'WAITING'
   AND wait_class IN ('User I/O', 'System I/O')
 GROUP BY
       sql_plan_hash_value,
       sql_plan_line_id,
       sql_plan_operation,
       sql_plan_options,
       wait_class, 
       event,
       current_obj#
 ORDER BY
       sql_plan_hash_value,
       sql_plan_line_id,
       sql_plan_operation,
       sql_plan_options,
       wait_class, 
       event,
       current_obj#;
VAR tables_list CLOB;
EXEC :tables_list := NULL;
-- get list of tables from execution plan
-- format (('owner', 'table_name'), (), ()...)
DECLARE
  l_pair VARCHAR2(32767);
BEGIN
  DBMS_LOB.CREATETEMPORARY(:tables_list, TRUE, DBMS_LOB.SESSION);
  FOR i IN (WITH object AS (
  	    SELECT /*+ MATERIALIZE */
  	           object_owner owner, object_name name
  	      FROM gv$sql_plan
  	     WHERE inst_id IN (SELECT inst_id FROM gv$instance)
  	       AND sql_id = '&&sql_id.'
  	       AND object_owner IS NOT NULL
  	       AND object_name IS NOT NULL
  	     UNION
  	    SELECT object_owner owner, object_name name
  	      FROM dba_hist_sql_plan
  	     WHERE :license = 'Y'
  	       AND dbid = :dbid
  	       AND sql_id = '&&sql_id.'
  	       AND object_owner IS NOT NULL
  	       AND object_name IS NOT NULL
  	    )
  	    SELECT 'TABLE', t.owner, t.table_name
  	      FROM dba_tab_statistics t, -- include fixed objects
  	           object o
  	     WHERE t.owner = o.owner
  	       AND t.table_name = o.name
  	     UNION
  	    SELECT 'TABLE', i.table_owner, i.table_name
  	      FROM dba_indexes i,
  	           object o
  	     WHERE i.owner = o.owner
  	       AND i.index_name = o.name)
  LOOP
    IF l_pair IS NULL THEN
      DBMS_LOB.WRITEAPPEND(:tables_list, 1, '(');
    ELSE
      DBMS_LOB.WRITEAPPEND(:tables_list, 1, ',');
    END IF;
    l_pair := '('''||i.owner||''','''||i.table_name||''')';
    DBMS_LOB.WRITEAPPEND(:tables_list, LENGTH(l_pair), l_pair);
  END LOOP;
  IF l_pair IS NULL THEN
    l_pair := '(''DUMMY'',''DUMMY'')';
    DBMS_LOB.WRITEAPPEND(:tables_list, LENGTH(l_pair), l_pair);
  ELSE
    DBMS_LOB.WRITEAPPEND(:tables_list, 1, ')');
  END IF;
END;
/
SET LONG 2000000 LONGC 2000 LIN 32767;
COL tables_list NEW_V tables_list FOR A32767 NOPRI;
SELECT :tables_list tables_list FROM DUAL;
PRO
PRO Tables Accessed 
PRO ~~~~~~~~~~~~~~~
COL table_name FOR A50;
SELECT owner||'.'||table_name table_name,
       partitioned,
       degree,
       temporary,
       blocks,
       num_rows,
       sample_size,
       TO_CHAR(last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       global_stats,
       compression
  FROM dba_tables
 WHERE (owner, table_name) IN &&tables_list.
 ORDER BY
       owner,
       table_name;
PRO
PRO Indexes 
PRO ~~~~~~~
COL table_and_index_name FOR A70;
COL degree FOR A6;
SELECT i.table_owner||'.'||i.table_name||' '||i.owner||'.'||i.index_name table_and_index_name,
       i.partitioned,
       i.degree,
       i.index_type,
       i.uniqueness,
       (SELECT COUNT(*) FROM dba_ind_columns ic WHERE ic.index_owner = i.owner AND ic.index_name = i.index_name) columns,
       i.status,
       i.visibility,
       i.blevel,
       i.leaf_blocks,
       i.distinct_keys,
       i.clustering_factor,
       i.num_rows,
       i.sample_size,
       TO_CHAR(i.last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       i.global_stats
  FROM dba_indexes i
 WHERE (i.table_owner, i.table_name) IN &&tables_list.
 ORDER BY
       i.table_owner,
       i.table_name,
       i.owner,
       i.index_name;
-- compute low and high values for each table column
DELETE plan_table WHERE statement_id = 'low_high';
DECLARE
  l_low VARCHAR2(256);
  l_high VARCHAR2(256);
  FUNCTION compute_low_high (p_data_type IN VARCHAR2, p_raw_value IN RAW)
  RETURN VARCHAR2 AS
    l_number NUMBER;
    l_varchar2 VARCHAR2(256);
    l_date DATE;
  BEGIN
    IF p_data_type = 'NUMBER' THEN
      DBMS_STATS.convert_raw_value(p_raw_value, l_number);
      RETURN TO_CHAR(l_number);
    ELSIF p_data_type IN ('VARCHAR2', 'CHAR', 'NVARCHAR2', 'CHAR2') THEN
      DBMS_STATS.convert_raw_value(p_raw_value, l_varchar2);
      RETURN l_varchar2;
    ELSIF SUBSTR(p_data_type, 1, 4) IN ('DATE', 'TIME') THEN
      DBMS_STATS.convert_raw_value(p_raw_value, l_date);
      RETURN TO_CHAR(l_date, 'YYYY-MM-DD HH24:MI:SS');
    ELSE
      RETURN RAWTOHEX(p_raw_value);
    END IF;
  END compute_low_high;
BEGIN
  FOR i IN (SELECT owner, table_name, column_name, data_type, low_value, high_value
              FROM dba_tab_cols
             WHERE (owner, table_name) IN &&tables_list.)
  LOOP
    l_low := compute_low_high(i.data_type, i.low_value);
    l_high := compute_low_high(i.data_type, i.high_value);
    INSERT INTO plan_table (statement_id, object_owner, object_name, object_alias, partition_start, partition_stop)
    VALUES ('low_high', i.owner, i.table_name, i.column_name, l_low, l_high);
  END LOOP;
END;
/
PRO
PRO Table Columns 
PRO ~~~~~~~~~~~~~
SET LONG 200 LONGC 20;
COL table_and_column_name FOR A70;
COL data_type FOR A20;
COL data_default FOR A20;
COL low_value FOR A32;
COL high_value FOR A32;
SELECT c.owner||'.'||c.table_name||' '||c.column_name table_and_column_name,
       c.data_type,
       c.nullable,
       c.data_default,
       c.num_distinct,
       NVL(p.partition_start, c.low_value) low_value,
       NVL(p.partition_stop, c.high_value) high_value,
       c.density,
       c.num_nulls,
       c.num_buckets,
       c.histogram,
       c.sample_size,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       c.global_stats,
       c.avg_col_len
  FROM dba_tab_cols c,
       plan_table p
 WHERE (c.owner, c.table_name) IN &&tables_list.
   AND p.statement_id(+) = 'low_high'
   AND p.object_owner(+) = c.owner
   AND p.object_name(+) = c.table_name
   AND p.object_alias(+) = c.column_name
 ORDER BY
       c.owner,
       c.table_name,
       c.column_name;
PRO
PRO Index Columns 
PRO ~~~~~~~~~~~~~
COL index_and_column_name FOR A70;
SELECT i.index_owner||'.'||i.index_name||' '||c.column_name index_and_column_name,
       c.data_type,
       c.nullable,
       c.data_default,
       c.num_distinct,
       NVL(p.partition_start, c.low_value) low_value,
       NVL(p.partition_stop, c.high_value) high_value,
       c.density,
       c.num_nulls,
       c.num_buckets,
       c.histogram,
       c.sample_size,
       TO_CHAR(c.last_analyzed, 'YYYY-MM-DD HH24:MI:SS') last_analyzed,
       c.global_stats,
       c.avg_col_len
  FROM dba_ind_columns i,
       dba_tab_cols c,
       plan_table p
 WHERE (i.table_owner, i.table_name) IN &&tables_list.
   AND c.owner = i.table_owner
   AND c.table_name = i.table_name
   AND c.column_name = i.column_name
   AND p.statement_id(+) = 'low_high'
   AND p.object_owner(+) = c.owner
   AND p.object_name(+) = c.table_name
   AND p.object_alias(+) = c.column_name
 ORDER BY
       i.index_owner,
       i.index_name,
       i.column_position;
-- spool off and cleanup
PRO
PRO planx_&&sql_id..txt is the text report
SET FEED ON VER ON LIN 80 PAGES 14 LONG 80 LONGC 80 TRIMS OFF;
SPO OFF;
UNDEF 1 2
-- end

