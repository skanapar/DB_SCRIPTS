#!/bin/bash
#
# Name:   move_spfile_asm_dg.sh
# Version 1.0
# Modified: 12-Dec-2019
#Purpose:  Moves spfile to ASm and updates Oracle_home/dbsXXX entries 
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


 . ${BASE_DIR}/../config/set_environme*asm*env
HOSTS=`olsnodes`

echo $HOSTS
. ~oracle/${CONTAINER}.env >/dev/null;
if [ $? -ne 0 ]
then
echo "Unable to Set environment for $ORACLE_SID"
exit 3
fi
set -x

for host in $HOSTS 
do
node_suffix=`echo $host|rev|cut -c1`

ssh  $host "echo spfile='+DATAC1/${ORACLE_UNQNAME}/spfile${CONTAINER}.ora' > $ORACLE_HOME/dbs/init${CONTAINER}${node_suffix}.ora"
ssh $host cat $ORACLE_HOME/dbs/init${CONTAINER}${node_suffix}.ora
done





sqlplus   "/as sysdba" <<EOF
whenever sqlerror exit 99
whenever oserror exit 98
create spfile='+DATAC1/${ORACLE_UNQNAME}/spfile${CONTAINER}.ora' from pfile='/db_share/DG/spfile_${CONTAINER}_TGT'
/
EOF
