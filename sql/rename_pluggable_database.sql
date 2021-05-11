alter session set container=&1;
alter pluggable database &1 close immediate instances=all;
alter  pluggable database &1 open restricted force;
alter pluggable database &1 rename global_name  to &&new_name;
alter pluggable database close immediate instances=all;
alter session set container=&&new_name;
alter pluggable database &&new_name open instances=all;

