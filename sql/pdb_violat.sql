select message, cause from PDB_PLUG_IN_VIOLATIONS where name='&new_pdb' and
status<>'RESOLVED' order by cause, message
/
