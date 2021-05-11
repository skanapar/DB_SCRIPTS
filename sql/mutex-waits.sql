select event, p1, cnt,
    CASE WHEN (event LIKE 'library cache:%' AND p1 <= power(2,17)) THEN
    'library cache bucket: '||p1   
    ELSE  
       (SELECT kglnaobj 
         FROM x$kglob 
         WHERE
           kglnahsh=p1 AND (kglhdadr = kglhdpar) and rownum=1) 
    END mutex_object
from 
   (select p1,event,count(*) cnt 
    from v$active_session_history 
    where
       p1text='idn' and session_state='WAITING'
       group by p1,event)
order by cnt desc;
