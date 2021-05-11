set lines 300
col pdb_name format a12
col owner format a20
col synonyms format a180
SELECT p.PDB_ID, p.PDB_NAME, t.OWNER,
 listagg(t.synonym_name, '|')  within group (order by t.synonym_name asc) synonyms
  FROM DBA_PDBS p, CDB_synonyms t
  WHERE p.PDB_ID > 2 AND
        t.OWNER IN('C##OMC_USER') and
        p.PDB_ID = t.CON_ID
group by  p.PDB_ID, p.PDB_NAME, t.OWNER
/

