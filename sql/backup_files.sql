set pages 1000
set line 500
column bytes format 999999999999
alter session set nls_date_format='MMDDYY-HH24:MI:SS';
select 
--	fname||' '||bytes||' '||bs_stamp||' '||tag||' '||decode(bs_type,'DATAFILE','D','ARCHIVE LOG','A','O')||' '||bs_completion_time
fname, bs_stamp, device_type, bs_type, tag, bs_completion_time
from v$backup_files 
	where file_type='PIECE'
	and device_type='DISK'
	and bs_incr_type='FULL'
	and status='AVAILABLE'
	and bs_status='AVAILABLE'
	and obsolete='NO'
	and bs_completion_time > trunc(sysdate)-3
order by bs_completion_time;
