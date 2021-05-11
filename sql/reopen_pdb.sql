alter session set container=&1 ;
 alter pluggable database &1 close immediate instances=all;
 alter pluggable database &1 open instances=all;
