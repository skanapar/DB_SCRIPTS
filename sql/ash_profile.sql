set lines 132
set verify off
col sample_time for a35
col sql_id for a14
col child for 99999
col file_block for a15
col blocking for a10
col seconds_waited for 999,999.99
col avg_waited for 999,999.99
col percent_of_time for 999.99
accept since_when -
       prompt 'Enter Earliest Event Date: ' -
       default sysdate-1
accept to -
       prompt 'Enter Latest Event Date: ' -
       default sysdate
select
event,
count(*) times_waited,
sum(time_waited/1000000) seconds_waited,
(sum(time_waited/1000000))/count(*) avg_waited,
round(ratio_to_report (sum(time_waited/1000000))  over () * 100,2) percent_of_time
from dba_hist_active_sess_history
where event like nvl('&event',event)
-- and sample_time between '03-may-06 10.00.00.000 AM'
-- and '03-MAY-06 11.00.00.000 AM'
and sample_time between &&since_when and &&to
group by
event
order by 3 desc
/
undef since_when
undef to

