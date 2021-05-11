set lines 200
col  message format a120
col  name format a20
select name, message, status, type
 from PDB_PLUG_IN_VIOLATIONS
/
