break on tablespace_name
col table_name for a28
col extents for 9999999
col InitialMB for 9999999
col NextMB for 9999999
col MinExt for 9999999
col MaxExt for 99999999999
set pagesize 100
col TABLESPACE_NAME for a16
col freelists heading "FLst" format 9999
col Analyze heading "Analyze" format a11
set linesize 300
select  
        t.TABLESPACE_NAME tablespace_name, 
        table_name , 
        t.ini_trans,
        t.freelists,
        t.buffer_pool,
        extents, 
        round(t.initial_extent/1024/1024) InitialMB, 
        round(t.next_extent/1024/1024) NextMB, 
        t.min_extents MinExt, 
        t.max_extents MaxExt,
        to_char(last_analyzed,'DD-MON-YYYY') Analyze
from user_tables t, 
	user_segments s
where t.table_name=s.segment_name
and t.table_name like upper('&table_name%')
order by 1,2
/

