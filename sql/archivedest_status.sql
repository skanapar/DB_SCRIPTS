set lines 132
set pages 132
col dest_name for a40
col status for a10
col value for a50
select inst_id,dest_id,dest_name,status from gv$archive_DEST
where dest_id in ( 1,2)
/

select inst_id,value from gv$parameter where name = 'log_archive_dest_2'
/
