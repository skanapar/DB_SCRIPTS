column "Rollback Segment"       format a16
column "Size (Kb)"              format 9,999,999
column "Gets"                   format 999,999,990
column "Waits"                  format 9,999,990
column "% Waits"                format 90.00
column "# Shrinks"              format 999,990
column "# Extends"              format 999,990

Prompt
Prompt Rollback Segment Statistics...

Select rn.Name "Rollback Segment", rs.RSSize/1024 "Size (KB)", rs.Gets
"Gets",
      rs.waits "Waits", (rs.Waits/rs.Gets)*100 "% Waits",
      rs.Shrinks "# Shrinks", rs.Extends "# Extends"
from   sys.v_$RollName rn, sys.v_$RollStat rs
where  rn.usn = rs.usn
/