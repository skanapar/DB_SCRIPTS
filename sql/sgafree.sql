col value for 999999999999 heading "Shared Pool size"
col bytes for 999999999999 heading "Free Bytes"
select v$sgastat.pool,to_number(v$parameter.value) value,v$sgastat.bytes,
100-(v$sgastat.bytes/v$parameter.value)*100 pct
from v$sgastat,v$parameter
where v$sgastat.name ='free memory'
and v$parameter.name ='shared_pool_size'
and v$sgastat.pool='shared pool';
