select 
    se.snap_id
    , begin_interval_time 
    , sum(time_waited_micro_fg)/1000000 total_waited_secs
 from DBA_HIST_SYSTEM_EVENT se, DBA_HIST_SNAPSHOT sn
 where 
    se.snap_id = sn.snap_id and
    wait_class='System I/O' and
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