declare 
cntr number := 0;
vstarttime date ;
vtimetorun number := 45;
begin
select sysdate into vstarttime from dual;
delete previous_events;
delete colevents;
commit;
insert into previous_events select sysdate,event,total_waits,total_timeouts,time_waited,average_wait,0
  from v$system_event
where event like 'log file sync%'
or event like 'latch free%';
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
	   and  a.event like 'log file sync%'
           or  a.event like 'latch free%';
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
