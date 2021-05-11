set heading off
set feedback off
col name format a20
select name from v$pdbs
where name like  'PAY%'
or name like 'PHI%'
or name like 'FIN%'
/

