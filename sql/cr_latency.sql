prompt The average cr block receive time or current block receive time should typically be  less than 15 milliseconds depending on your system configuration and volume, is the  average latency of a consistent-read request round-trip from the requesting instance  to the holding instance and back to the requesting instance.
set lines 132
set numwidth 20 
column "AVG CR BLOCK RECEIVE TIME (ms)" format 9999999.9 

select b1.inst_id, b2.value "GCS CR BLOCKS RECEIVED",  
b1.value "GCS CR BLOCK RECEIVE TIME", 
((b1.value / b2.value) * 10) "AVG CR BLOCK RECEIVE TIME (ms)" 
from gv$sysstat b1, gv$sysstat b2 
where b1.name = 'global cache cr block receive time' and 
b2.name = 'global cache cr blocks received' and b1.inst_id = b2.inst_id ;
