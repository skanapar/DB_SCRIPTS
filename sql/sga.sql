set lines 200
col name format a12
col value format a30
select d.name, pdb.name, p.name, value/1048576
from v$parameter p, v$database d,  V$pdbs pdb
where p.name like 'sg%%'
/

