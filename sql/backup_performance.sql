SELECT 
open_time, 
to_char(open_time, 'day'), 
(close_time-open_time)*24, 
round((effective_bytes_per_second/1024/1024)) EB
FROM V$BACKUP_ASYNC_IO
--WHERE to_char(OPEN_TIME, 'day') = 'wednesday'
where open_time > sysdate-3
and TYPE='OUTPUT'
AND FILENAME LIKE 'fbk%'
