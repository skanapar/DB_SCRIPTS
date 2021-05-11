--exec all_pdb_exec('select value/(1048576*1024) gb from v$spparameter where name=''sga_target''');
exec all_pdb_exec('select value/(1048576*1024) gb from v$parameter where name=''sga_target''');
--exec all_pdb_exec('select count(*) from v$spparameter where name=''sga_target''');
