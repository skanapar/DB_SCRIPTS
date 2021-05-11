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


if (( $# < 1 ))
then
  echo " Argument: SQL_FILE Expected "
fi
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
        DB_NAME=`echo $ORACLE_SID|rev|cut -c 2-|rev`
              . ~oracle/${DB_NAME}.env >/dev/null;

PDBS=`${BIN_DIR}/get_pdbs.sh|grep -v "^#"|grep -v SEED`
TIMESTAMP=$(date +"%Y%m%d_%H%M%S"); export TIMESTAMP

for pdb in $PDBS
do

  if grep  -q $pdb  $ORACLE_HOME/network/admin/tnsnames.ora 
  then 
    echo "$pdb found"
    else
        echo $pdb not found
          cp -p $ORACLE_HOME/network/admin/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora.${TIMESTAMP}
            sleep 5
echo "$pdb =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = npphx21-2ossa-scan.npdbphx.npphx.oraclevcn.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${pdb}.npdbphx.npphx.oraclevcn.com)
    )
  )"   >>$ORACLE_HOME/network/admin/tnsnames.ora
fi
echo $ORACLE_HOME
done
done

##paydmo1.npdbphx.npphx.oraclevcn.com
