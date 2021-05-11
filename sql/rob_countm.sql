set verify off
set pages 1000
set line 132
set long 1500
set head on
break on report
compute sum of "OPEN TICKETS" on report
compute sum of "CLOSED TICKETS" on report
accept dia date format 'MM-YY' prompt 'Tickets for month? (MM-YY): '
spool output/countm
select a.user_id "ASSIGNED TO",  b.group_id "GROUP NAME",
sum(decode(to_char(nvl(open_date,sysdate+100),'MM'),to_char(to_date('&dia','MM-YY'),'MM'),1,0)) "OPEN TICKETS",
sum(decode(to_char(nvl(close_date,sysdate+100),'MM'),to_char(to_date('&dia','MM-YY'),'MM'),1,0)) "CLOSED TICKETS"
from problems a, member_of b, users_view c
where a.user_id=b.user_id and
b.user_id = c.user_id and
c.user_active_flag = 1 and
b.group_id like 'SP %'
group by a.user_id, b.group_id
order by a.user_id, b.group_id
/
spool off
