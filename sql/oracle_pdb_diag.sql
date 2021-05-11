spool cdb_pdb_status.html
set markup html on
set lines 200 long 2000000000 longchunksize 2000000 pages 0 embedded on echo on verify on
col name format a20
col open_time format a40
col pdb_name format a30
col time format a30
col guid format a50
col action format a60
col message format a60
col value format a60
col schema format a25
col comp_name format a40
col parameter format a60
col restricted heading RESTRICTED format a11
select NAME, DECODE(CDB, 'YES', 'Multitenant Option enabled', 'Regular 12c Database: ') "Multitenant Option ?", OPEN_MODE, CON_ID from gv$database;
select name, open_mode, restricted, open_time, inst_id, con_id, dbid, con_uid, guid from gv$containers order by con_id;
select name, open_mode, restricted, open_time, inst_id, con_id, dbid, con_uid, guid from gv$pdbs order by con_id;
select pdb_id, pdb_name, dbid, con_uid, con_id, status from cdb_pdbs order by 1;
show pdbs
select * from registry$history order by action_time desc;
select patch_id, action, action_time, description, bundle_series from dba_registry_sqlpatch;
break on con_id skip 1
select con_id, comp_id, comp_name, version, status, schema from cdb_registry order by con_id, status -- not showing for PDB$SEED if run from CDB$ROOT;
clear breaks
select comp_id, comp_name, version, status, schema from dba_registry order by status;
select parameter, value from nls_database_parameters where parameter like '%CHARACTERSET';
select * from pdb_plug_in_violations order by time desc;
set markup html off
spool off
