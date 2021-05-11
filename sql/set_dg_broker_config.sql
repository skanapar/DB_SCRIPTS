set echo on term on
select name, db_unique_name from v$database;
alter system set dg_broker_start=false;
alter system set dg_broker_config_file1='+DATAC1/&1/dgcfg1.dat' ;
alter system set dg_broker_config_file2='+DATAC1/&1/dgcfg2.dat' ;
show parameter dg
alter system set dg_broker_start=true;
show parameter dg
