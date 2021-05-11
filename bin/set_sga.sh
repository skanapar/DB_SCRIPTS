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
 
for rec in `ps -ef|grep pmon|grep -v grep | grep -v perl| grep -v ASM|grep -v APX|awk '{print $8}'`
do
 
        str_length=${#rec}
        str_to_cut="ora_pmon_"
        #ORACLE_SID=${rec:${#str_to_cut}-1:$str_length-1}
        ORACLE_SID=${rec:9:$str_length-1}
        ORACLE_SID=`echo $rec|cut -c10-18`
        str_length=${#ORACLE_SID}
        ORACLE_DB=${ORACLE_SID:0:$str_length-1}
        SGA_SIZE=`grep $ORACLE_DB ${BIN_DIR}/sga_sizes.txt|awk -F "," '{print $2}'`
echo $SGA_SIZE
        if (( SGA_SIZE > 7 ))
        then
          ((SGA_SIZE=SGA_SIZE+2))
echo $SGA_SIZE
           echo "need to set SGA for $ORACLE_DB to $SGA_SIZE"
          . ~/${ORACLE_DB}.env
if [[ $? -ne 0 ]]
then
echo  -e $RED "DB not found" $WHITE
else
sqlplus  -s "/as sysdba" <<EOF
set echo on
alter system set sga_max_size=${SGA_SIZE}G scope=spfile;
alter system set sga_target=${SGA_SIZE}G scope=spfile;
EOF

fi

 
        fi
 
done
