select to_char(round(end_interval_time,'hh24'),'mm-dd hh24') snap_time
, instance_number
, sum(megabytes) / 1024 Gigabytes
from
(
select end_interval_time
, instance_number
, megabytes
from
(
select s.snap_id
, s.instance_number
, s.dbid
, s.end_interval_time
, case when s.begin_interval_time = s.startup_time
then nvl(ft.small_read_megabytes+large_read_megabytes,0)
else nvl(ft.small_read_megabytes+large_read_megabytes,0) -
lag(nvl(ft.small_read_megabytes+large_read_megabytes,0),1)
over (partition by ft.filetype_id
, ft.instance_number
, ft.dbid
, s.startup_time
order by ft.snap_id)
end megabytes
from dba_hist_snapshot s
, dba_hist_iostat_filetype ft
, dba_hist_iostat_filetype_name fn
where s.dbid = ft.dbid
and s.instance_number = ft.instance_number
and s.snap_id = ft.snap_id
and s.dbid = fn.dbid
and ft.filetype_id = fn.filetype_id
and end_interval_time between to_timestamp(:start_date,'MMDDYYYY')
and to_timestamp(:end_date,'MMDDYYYY')
and fn.filetype_name = 'Data File'
)
)
group by to_char(round(end_interval_time,'hh24'),'mm-dd hh24'), instance_number
order by to_char(round(end_interval_time,'hh24'),'mm-dd hh24'), instance_number