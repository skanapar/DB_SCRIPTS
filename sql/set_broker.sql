accept db_name 'Enter Primary CDB unique name: '
alter system set dg_broker_config_file1='+DATAC1/&&dbname/DATAGUARDCONFIG/dgcfg1.dat' scope=both sid='*';
alter system set dg_broker_config_file2='+RECOC1/&&dbname/DATAGUARDCONFIG/dgcfg2.dat' scope=both sid='*';
alter system set dg_broker_start=true scope=both sid='*';
show parameter broker
