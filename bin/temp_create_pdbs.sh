#!/bin/bash
#
# Name:   run_sql_all_instances_local_node.sh
# Version 1.0
# Modified: 12-Dec-2016
#Purpose:  Runs a sql script on all instances of this nodes excluding ASM and MGMT DB
# USAGE:run_sql_all_instances_local_node.sh sql_file
#       will pickup sql file from directory under ../sql directory if full path is not specified.
#       If Environment is configured then will use SQL file from env
# Dependencies:  Script framework,
# Modification Log:
 
 
#if (( $# < 1 ))
#then
#  echo " Argument: SQL_FILE Expected "
#fi
SQL_FILE=$1
 
BASE_DIR=$(dirname "$0"); export BASE_DIR
 
if [ ! -f ${BASE_DIR}/common_functions.sh ]
then
    echo "common_functions File not found!  in directory ${BASE_DIR}"
    exit 1
fi
source $BASE_DIR/common_functions.sh
 
 
if  ! [[ $ENVIRONMENT_SET = "Y" ]]
then
. ${BASE_DIR}/../config/set_environment_to_run_scripts.env
fi
exit_if_error $?
BASE_SQL_DIR=$(dirname "$SQL_FILE")
if   [[ $BASE_SQL_DIR = "." ]]
then
SQL_FILE="${SQL_DIR}/${SQL_FILE}"
fi
set +x
get_wallet_pass DUMMY
exit_if_error $?

 
for rec in `ps -ef|grep pmon|grep -v grep | grep -v perl| grep -v ASM|grep -v APX|awk '{print $8}'`
do
 
        str_length=${#rec}
        str_to_cut="ora_pmon_"
        #ORACLE_SID=${rec:${#str_to_cut}-1:$str_length-1}
        ORACLE_SID=${rec:9:$str_length-1}
        ORACLE_SID=`echo $rec|cut -c10-18`
        str_length=${#ORACLE_SID}
         ORACLE_DB=${ORACLE_SID:0:$str_length-1}
       echo $ORACLE_DB
       sleep 2
       PDBS=`grep $ORACLE_DB ${BIN_DIR}/cdb_pdb.txt|awk -F "," '{print $2}'`
if [[ ! -z ${PDBS} ]]
then
   echo -e ${PDBS}
    . ~/${ORACLE_DB}.env
if [[ $? -ne 0 ]]
then
echo  -e $RED "DB $ORACLE_DB not found" $WHITE
else
   echo  -e $GREEN "DB $ORACLE_DB  found" $WHITE
   for pdb in `echo $PDBS`
   do
   echo $pdb
   sqlplus / as sysdba <<EOF
   select name from v\$database
   /
   whenever sqlerror exit 99
   CREATE PLUGGABLE DATABASE "$pdb"
        ADMIN USER "admin" IDENTIFIED BY "$WALLET_PASS"
        STORAGE UNLIMITED
        TEMPFILE REUSE;
--        FILE_NAME_CONVERT='NONE';
   alter pluggable database $pdb OPEN;
   whenever sqlerror exit 99
   alter session set container=$pdb;

   administer key management set key force keystore identified by "$WALLET_PASS" with backup ;

EOF

   done

fi
 
        fi
 
done
