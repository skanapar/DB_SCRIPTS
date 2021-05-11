set pages 200

col sid form 99
col units form a7
col username form a8
col opname form a20
col target form a15
col start_time form a12 heading "Start Time"
col progress form 999 heading "%"
col elapsed_seconds form 999900 heading "Secs"

alter session set nls_date_format='YYYY/MON/DD HH24:MI';

select sid
      , username
      , opname
      , decode(totalwork,0,0,null,0,sofar*100/totalwork) progress
      , totalwork
      , units
      , start_time
      , elapsed_seconds
from v$session_longops
order by sid, start_time
/
