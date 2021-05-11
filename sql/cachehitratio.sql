-- Get initial Buffer Hit Ratio reading...
SELECT ROUND((1-(phy.value / (cur.value + con.value)))*100,2) "Cache Hit
Ratio"
 FROM v$sysstat cur, v$sysstat con, v$sysstat phy
WHERE cur.name = 'db block gets'
  AND con.name = 'consistent gets'
  AND phy.name = 'physical reads'
/

-- Let's artificially increase the buffer hit ratio...
DECLARE
 v_dummy dual.dummy%TYPE;
BEGIN
 FOR I IN 1..1000 LOOP
   SELECT dummy INTO v_dummy FROM dual;
 END LOOP;
END;
/

-- Let's measure it again...
SELECT ROUND((1-(phy.value / (cur.value + con.value)))*100,2) "Cache Hit
Ratio"
 FROM v$sysstat cur, v$sysstat con, v$sysstat phy
WHERE cur.name = 'db block gets'
  AND con.name = 'consistent gets'
  AND phy.name = 'physical reads'
/