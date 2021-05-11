column event format a60
SELECT event,
count(*) as wait_count
FROM v$session_wait
WHERE event not like '%SQL*Net%'
AND   event not in
('pmon timer',
 'rdbms ipc message',
 'smon timer',
 'queue messages',
 'wakeup time manager',
 'unread message',
 'db file sequential read',
 'jobq slave wait',
 'PX Deq%',
 'PL/SQL lock timer')
AND seconds_in_wait > 1
GROUP BY event
ORDER BY 2 desc,1;