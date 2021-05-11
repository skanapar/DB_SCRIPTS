set lines 120
set pagesize 99
set verify off
select plan_table_output
from table(dbms_xplan.display
  ('plan_table',
  '','SERIAL'))
/
