col name format a40
col value format a40
col db_uniq_name format a30
set lines 200
select p.name, s.name, value$ value
from pdb_spfile$ s, v$pdbs p
where s.name like '%unnest_sub%'
and s.PDB_UID=p.CON_UID
order by 2
/

