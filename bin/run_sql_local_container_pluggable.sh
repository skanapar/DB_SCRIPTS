#!/bin/bash
#
# Name:   run_sql_local_container-pluggable.sh
# Version 1.0
# Modified: 12-Dec-2016
#Purpose:  runs a sql script locally on this node
# USAGE: run_sql_local.sh CONTAINER_NAME PDB_NAME SQL_FILE
# Dependencies:  Script framework, get_database_instances_running_this_node.sh, get_listeners_running_this_node.sh
# Modification Log:

if (( $# < 2 ))
then
  echo " Argument:   CONTAINER_NAME PDB_NAME SQL_FILE Expected "
fi

CONTAINER=$1;
PDB_NAME=$2;
SQL_FILE=$3

BASE_DIR=$(dirname "$0"); export BASE_DIR
SCRIPT_NAME=$(basename "$0"); export SCRIPT_NAME
sql_file=$(basename "$2"); export sql_file

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


LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER}_${sql_file}_${LOG_SUFFIX}.log
echo $LOG_FILE
sleep 1
exec > >(tee -i ${LOG_FILE})
exec 2>&1
date 


. ~oracle/${CONTAINER}.env >/dev/null;
if [ $? -ne 0 ]
then
echo "Unable to Set environment for $ORACLE_SID"
exit 3
fi
sqlplus  -s "/as sysdba" <<EOF
whenever sqlerror exit 99
whenever oserror exit 98
alter session set container=${PDB_NAME};
start ${SQL_FILE} $4 $5
EOF
