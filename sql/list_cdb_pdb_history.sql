col pdb_name format a15
col CLONED_FROM_PDB_NAME format a15


select pdb_name, CLONED_FROM_PDB_NAME,op_timestamp
from CDB_PDB_HISTORY
/
