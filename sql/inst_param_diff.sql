column inst_id format 99
column name format a25
column value format a60
select a.INST_ID, a.name, a.value, b.inst_id, b.name, b.value
from 
(select * from gv$parameter where inst_id=1) a,
(select * from gv$parameter where inst_id=2) b
where
a.name=b.name
and a.value <> b.value
and a.name not in
 ('cluster_interconnects',
  'thread',
  'undo_tablespace',
  'instance_number',
  'instance_name',
  'local_listener',
  'core_dump_dest')
/
