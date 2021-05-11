
select 'clone_pdb_over_dblink.sh -s '|| name||' -t '|| name||
      ' -l '||name||' -C '||(select name from v$database)
from v$pdbs
where name not like '%SEED'
/
