select 
fname, bytes, bs_stamp, tag, bs_type, bs_completion_time
from v$backup_files 
where file_type='PIECE'
and device_type='DISK'
and bs_incr_type='FULL'
and status='AVAILABLE'
and bs_status='AVAILABLE'
and obsolete='NO'
and bs_completion_time > trunc(sysdate)-1
order by bs_completion_time