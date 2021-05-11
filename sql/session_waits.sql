SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30
COLUMN wait_class FORMAT A15

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
       and sw.wait_class <> 'Idle'
ORDER BY sw.seconds_in_wait DESC;
