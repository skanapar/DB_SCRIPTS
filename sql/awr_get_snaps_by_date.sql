select
    min(snap_id),
    max(snap_id)
from DBA_HIST_SNAPSHOT
where
    extract(month from BEGIN_INTERVAL_TIME)= &month and
    extract(day from BEGIN_INTERVAL_TIME)= &day
