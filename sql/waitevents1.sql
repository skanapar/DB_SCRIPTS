declare 
cntr number := 0;
vstarttime date ;
vtimetorun number := 30;
begin
select sysdate into vstarttime from dual;
delete previous_events;
delete colevents;
commit;
insert into previous_events select sysdate,event,total_waits,total_timeouts,time_waited,average_wait,0
  from v$system_event
where event not like '%SQL*Net%' 
and event not like '%timer%'
and event not like '%idle%'
and event not like '%Idle%'
and event not like '%PX Deq%'
and event not like '%rdbms ipc%'
and event not like '%Null event%'
and event not like '%file open%'      
and event not like '%PX Idle Wait%'
and event not like '%timer%'
and event not like 'gcs remote message'
and event not like 'ges remote message';
loop
        dbms_lock.sleep (5);
        cntr := cntr + 1;
        Insert into colevents (TIMESTAMP,EVENT,TOTAL_WAITS,TIME_WAITED,TOTAL_TIMEOUTS)
        SELECT   sysdate,
                 A.event,
                 A.total_waits - NVL (B.total_waits, 0) total_waits,
                 A.time_waited - NVL (B.time_waited, 0) time_waited,
                 A.total_timeouts - NVL (B.total_timeouts, 0) total_timeouts
        FROM     v$system_event A, previous_events B
        WHERE    B.event (+) = A.event
           and a.event not like '%SQL*Net%' 
           and a.event not like '%timer%'
           and a.event not like '%idle%'
           and a.event not like '%Idle%'
           and a.event not like '%PX Deq%'
           and a.event not like '%rdbms ipc%'
           and a.event not like '%Null event%'
           and a.event not like '%file open%'      
           and a.event not like '%PX Idle Wait%'
           and a.event not like '%timer%'
           and a.event not like 'gcs remote message'
           and a.event not like 'ges remote message';
        delete from previous_events;
        insert into previous_events select sysdate,event,total_waits,total_timeouts,time_waited,average_wait,0
                                      from v$system_event;
        commit;
        if ((sysdate - vstarttime)/(24*60) > vtimetorun) then
           exit;
        end if;
--      if cntr > 1500 then
--         exit;
--      end if;
end loop;
end;
/
