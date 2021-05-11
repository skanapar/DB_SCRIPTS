set lines 255
set verify off
select * from v$sql_shared_cursor
where sql_id = '&sql_id'
and rownum < 10
/
