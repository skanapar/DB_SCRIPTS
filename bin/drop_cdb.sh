#!/bin/bash
#
# Name:   drop_cdb.sh
# Version 1.0
# Modified: 12-Dec-2019
#Purpose:  runs a sql script locally on this node
# USAGE: run_sql_local.sh CONTAINER 
# Dependencies:  Script framework, get_database_instances_running_this_node.sh, get_listeners_running_this_node.sh
# Modification Log:

usage() { echo "Usage: $0  -t target_cdb_name  " 1>&2; exit 1; }

while getopts ":t:" o; do
    case "${o}" in
        t)
            TARGET_CDB_NAME=${OPTARG}
            ;;
        r)
            REMOTE_NODE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z ${TARGET_CDB_NAME} ]]
then
usage
fi
CONTAINER=${TARGET_CDB_NAME};

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
set -x
echo "***************dropping database ${CONTAINER}   ************"
read -p "Are you sure? " -n 1 -r
sqlplus  -s "/as sysdba" <<EOF
alter user sys identified by Dr0P_CDB_NOW
/
EOF

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
 dbca -silent -deleteDatabase -sourceDB $ORACLE_UNQNAME -sysDBAUserName sys -sysDBAPassword 'Dr0P_CDB_NOW'
exit


