--set heading off
set feedback off
set lines 200
col db_unique_name format a20
col "PDB NAME" Format a20

spool &1
set markup html on
alter session set nls_date_format='YYYY-MON-DD '
/
select d.name "DB NAME", d.db_unique_name ,  p.name "PDB NAME", p.creation_time
from v$pdbs p, v$database d
order by 2

/
set markup html off
spool off
