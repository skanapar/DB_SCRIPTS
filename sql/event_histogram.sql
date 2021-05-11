compute sum of wait_count on report
col event for a30 trunc
break on report on event
select event, wait_time_milli bucket, wait_count
 from v$event_histogram
--  where event = 'enq: TX - row lock contention'
    where event like nvl('&event',event)
/
