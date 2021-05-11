#!/bin/bash
#
# Name:  delete_dg_config.sh 
# Version 1.0
# Modified: 12-Dec-2019
#Purpose:  Creates DG config
# USAGE:create_dg_config.sh
#      
#     
# Dependencies:  Script framework,
# Modification Log:
BASE_DIR=$(dirname "$0"); export BASE_DIR

usage() { echo "Usage: $0 -s source_cdb_name  -t target_cdb_name  -r REMOTE_NODE " 1>&2; exit 1; }

while getopts ":s:t:r:" o; do
    case "${o}" in
        s)
            SOURCE_CDB_NAME=${OPTARG}
            ;;
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

if [[ -z ${SOURCE_CDB_NAME} || -z ${TARGET_CDB_NAME} || -z ${REMOTE_NODE} ]]
then
usage
fi

BASE_DIR=$(dirname "$0"); export BASE_DIR
SCRIPT_NAME=$(basename "$0"); export SCRIPT_NAME

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
TIMESTAMP=$(date +"%Y%m%d_%H%M%S"); export TIMESTAMP


TIMESTAMP=$(date +"%Y%m%d_%H%M%S"); export TIMESTAMP

exit_if_error $?
. ~/${TARGET_CDB_NAME}.env

TGT_UNIQ=`cat ~oracle/${TARGET_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
SRC_UNIQ=`ssh ${REMOTE_NODE} cat ~oracle/${SOURCE_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
DB_NAME=`echo $SRC_UNIQ|cut -d"_" -f1`
TGT_DB_NAME=`echo $TGT_UNIQ|cut -d"_" -f1`
${BIN_DIR}/run_sql_local_container.sh ${TARGET_CDB_NAME}  stop_dg_broker.sql $ORACLE_UNQNAME
asmcmd --privilege sysdba rm +DATAC1/${TGT_UNIQ}/dgcfg1.dat
asmcmd --privilege sysdba rm +DATAC1/${TGT_UNIQ}/dgcfg2.dat
asmcmd --privilege sysdba ls +DATAC1/${TGT_UNIQ}/
ssh ${REMOTE_NODE1} " . ${SOURCE_CDB_NAME}.env; ${BIN_DIR}/run_sql_local_container.sh ${SOURCE_CDB_NAME}  stop_dg_broker.sql $SRC_UNIQ"
ssh ${REMOTE_NODE} " . ${SOURCE_CDB_NAME}.env; asmcmd --privilege  sysdba rm +DATAC1/${SRC_UNIQ}/dgcfg1.dat"
ssh ${REMOTE_NODE} " . ${SOURCE_CDB_NAME}.env; asmcmd --privilege  sysdba rm +DATAC1/${SRC_UNIQ}/dgcfg2.dat"
ssh ${REMOTE_NODE} " . ${SOURCE_CDB_NAME}.env; asmcmd --privilege  sysdba ls +DATAC1/${SRC_UNIQ}"







