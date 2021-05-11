set lines 120
col status format a20
col name format a30
col pdb_name format a20
set heading off
SELECT d.name db_name, p.name pdb_name, s.name, s.status
 FROM DBA_DV_STATUS s, v$pdbs p, v$database d
/
