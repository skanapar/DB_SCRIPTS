SELECT filetype_name,small_read_servicetime, small_write_servicetime,SMALL_SYNC_READ_LATENCY
, LARGE_READ_SERVICETIME,LARGE_WRITE_SERVICETIME   FROM DBA_HIST_IOSTAT_FILETYPE
where snap_id=25732
