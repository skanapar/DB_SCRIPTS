col c1 heading 'Begin|Interval|time' format a20
col c2 heading 'Search Columns'      format 999
col c3 heading 'SQL ID'              format a20
col c4 heading 'Invocation|Count'    format 99,999,999
 
break on c1 skip 2
 
accept idxname char prompt 'Enter Index Name: '
 
ttitle 'Invocation Counts for index|&idxname'
 
select
   to_char(sn.begin_interval_time,'yy-mm-dd hh24')  c1,
   p.search_columns                                 c2,
   p.sql_id                                         c3,
   count(*)                                         c4
from
   dba_hist_snapshot  sn,
   dba_hist_sql_plan   p,
   dba_hist_sqlstat   st
where
   st.sql_id = p.sql_id
and
   sn.snap_id = st.snap_id   
and   
   p.object_name = '&idxname'
group by
   begin_interval_time,search_columns,p.sql_id;