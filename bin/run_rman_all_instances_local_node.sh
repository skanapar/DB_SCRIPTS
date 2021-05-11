#!/bin/bash
#
# Name:   run_rmanall_instances_local_node.sh
# Version 1.0
# Modified: 12-Dec-2018
#Purpose:  Runs a rcv script on all instances of this nodes excluding ASM and MGMT DB
# USAGE:run_sql_all_instances_local_node.sh rcv_file
#       will pickup rcv file from directory under ../rcv directory if full path is not specified.
#       If Environment is configured then will use RCV file from env
# Dependencies:  Script framework,
# Modification Log:
 
 
if (( $# < 1 ))
then
  echo " Argument: RCV_FILE Expected "
fi
RCV_FILE=$1
 
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
BASE_RCV_DIR=$(dirname "$RCV_FILE")
if   [[ $BASE_RCV_DIR = "." ]]
then
RCV_FILE="${RCV_DIR}/${RCV_FILE}"
fi
 
for rec in `ps -ef|grep pmon|grep -v grep | grep -v perl| grep -v ASM|grep -v APX|awk '{print $8}'`
do
 
        str_length=${#rec}
        str_to_cut="ora_pmon_"
        #ORACLE_SID=${rec:${#str_to_cut}-1:$str_length-1}
        ORACLE_SID=${rec:9:$str_length-1}
        ORACLE_SID=`echo $rec|cut -c10-18`
        echo  connecting to $ORACLE_SID
        ${BIN_DIR}/run_rman_local.sh  $ORACLE_SID $RCV_FILE
 
done
