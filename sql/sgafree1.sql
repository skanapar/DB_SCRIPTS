set echo off
col value form 999,999,999,999 heading "Shared Pool Size MB"
col MB form 999,999,999,999 heading "Free MBs"
col percentfree form 999 heading "Percent Free"


select  pool
        , to_number(v$parameter.value)/1024/1024 value, v$sgastat.bytes/1024/1024 MB, 
	(v$sgastat.bytes/v$parameter.value)*100 percentfree
from 	v$sgastat, v$parameter
where	v$sgastat.name = 'free memory'
and	v$parameter.name = 'shared_pool_size';

