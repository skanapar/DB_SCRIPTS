select 
    se.snap_id
    , begin_interval_time 
    , sum(wait_time_milli*wait_count)/1000 total_waited_secs
 from DBA_HIST_EVENT_HISTOGRAM se, DBA_HIST_SNAPSHOT sn
 where 
    se.snap_id = sn.snap_id and
    wait_class in ('System I/O','User I/O') and
    se.snap_id between 
            (select min(snap_id)
            from DBA_HIST_SNAPSHOT
            where
                extract(month from BEGIN_INTERVAL_TIME)||
                extract(day from BEGIN_INTERVAL_TIME)= &begin_mmdd )
        and
            (select max(snap_id)
            from DBA_HIST_SNAPSHOT
            where
                extract(month from BEGIN_INTERVAL_TIME)||
                extract(day from BEGIN_INTERVAL_TIME)= &end_mmdd )
 group by se.snap_id, begin_interval_time
 order by se.snap_id