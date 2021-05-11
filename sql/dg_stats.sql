set pages 500
set line 200
column value format a20
SELECT name, value, datum_time, time_computed FROM V$DATAGUARD_STATS
/

