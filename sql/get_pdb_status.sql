col name format a10
col open_mode format a30
 select inst_id,  name , open_mode, restricted
 from gv$pdbs
/
