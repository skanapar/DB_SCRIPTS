export SRC=PRDPS1C
export TGT=PRDPS1C
./dg_step000prep_source_dg.sh -s $SRC -t $TGT -r $ASH1
./dg_step150_get_spfile.sh -s $SRC -t $TGT -r $ASH1
./dg_step200_drop_cdb.sh  -t $TGT
./dg_step300_add_cdb_tns_dg.sh
ssh  $ASH2 $PWD/dg_step300_add_cdb_tns_dg.sh
 ./dg_step400_register_db_clusterware.sh  -t $TGT
 ./dg_step500_move_spfile_asm_dg.sh  -t $TGT
./dg_step600_copy_wallet_from_dr_dg.sh -s $SRC -t $TGT -r $ASH1
./dg_step700_password_file_dr_dg.sh -s $SRC -t $TGT -r $ASH1
./dg_step800_restore_db_from_service.sh -s $SRC -t $TGT -r  $ASH1
./dg_step900_create_dg_config_dg.sh  -s $SRC -t $TGT -r $ASH1

