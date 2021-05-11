set lines 132
set pages  132
column d1 form a12 heading "Date"
column sw_cnt form 99999 heading 'Number|of|Switches'

select first_time d1,
          count(*) sw_cnt
from v$log_history
group by first_time;
