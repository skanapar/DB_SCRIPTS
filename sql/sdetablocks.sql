column table_name format a30
column owner format a10
column sde_dbid format a15
select 
to_char(pi.start_time,'MM/DD/YY HH24:MI') since,
tr.owner, tr.table_name,
tl.sde_id, tl.registration_id tab_regid, 
pi.owner sde_dbid, pi.server_id sde_os_procid
from table_locks tl, table_registry tr, process_information pi
where tl.registration_id = tr.registration_id
and tl.sde_id = pi.sde_id
order by tr.owner, tr.table_name, since
/
