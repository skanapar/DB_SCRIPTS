#!/bin/bash
#
# Name:   prep_source_dg.sh
# Version 1.0
# Modified: 12-Dec-2019
#Purpose:  prep_source_dg.sh
# USAGE:a prep_source_dg.sh -s source_cdb_name  -t target_cdb_name  -r REMOTE_NODE_HOSTING_SOURCE_CDB
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

. ~/${TARGET_CDB_NAME}.env
exit_if_error $?


SRC_UNIQ=`ssh ${REMOTE_NODE} cat ~oracle/${SOURCE_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
TGT_UNIQ=` cat ~oracle/${TARGET_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
TGT_DB_NAME=`echo $TGT_UNIQ|cut -d"_" -f1`
DB_NAME=`echo $SRC_UNIQ|cut -d"_" -f1`
ssh ${REMOTE_NODE} " . ${SOURCE_CDB_NAME}.env; ${BIN_DIR}/run_sql_local_container.sh ${SOURCE_CDB_NAME}  prep_source_dg.sql $TGT_DB_NAME $TGT_UNIQ "

