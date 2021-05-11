SET LINESIZE 150
COLUMN pdb_name FORMAT A10
COLUMN begin_time FORMAT A26
COLUMN end_time FORMAT A26
COLUMN sga_gb FORMAT 999.99
COLUMN pga_gb FORMAT 999.99
COLUMN bufcache_gb FORMAT 999.99
COLUMN shpool_gb FORMAT 999.99
ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD-MON-YYYY HH24:MI:SS.FF'; 

SELECT 
       r.con_id,
       r.snap_id,
       r.begin_time,
       round(r.sga_bytes/(1048576*1024),2) sga_gb,
       round(r.pga_bytes/(1048576*1024),2) pga_gb,
       round(r.buffer_cache_bytes/(1048576*1024),2) bufcache_gb,
       round(r.shared_pool_bytes/(1048576*1024),2) shpool_gb
FROM   dba_hist_rsrc_pdb_metric r,
       cdb_pdbs p
WHERE  r.con_id = p.con_id
AND    p.pdb_name = '&pdbname'
ORDER BY r.begin_time;
