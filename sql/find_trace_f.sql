select p.tracefile 
from gv$session s, GV$PROCESS p 
where s.sql_trace = 'ENABLED' 
  and s.username = 'E5_DATABASE' 
  and    s.paddr = p.addr 
  and    s.inst_id = p.inst_id
/