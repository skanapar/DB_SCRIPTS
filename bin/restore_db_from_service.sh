#!/bin/bash
#
# Name:   "restore_db_from_service.sh" 
# Version 1.0
# Modified: 2-Jan-2020
#Purpose:  Resstores database from service
# USAGE: "restore_db_from_service.sh -s Source_db -t target_db
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


if [[ -z ${SOURCE_CDB_NAME} || -z ${TARGET_CDB_NAME} ]]
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

SRC_UNIQ=`ssh ${REMOTE_NODE} cat ~oracle/${SOURCE_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`

. ~/${TARGET_CDB_NAME}.env
echo LG file is ${LOG_FILE}
rman  target /  LOG $LOG_FILE<<EOF
startup nomount;
set echo on
restore standby controlfile from service $SRC_UNIQ;
alter database mount;
CONFIGURE DEFAULT DEVICE TYPE TO DISK;
CONFIGURE DEVICE TYPE DISK PARALLELISM 16;
CONFIGURE CHANNEL DEVICE TYPE 'SBT_TAPE' clear;
CONFIGURE SNAPSHOT CONTROLFILE name clear;
CONFIGURE RETENTION POLICY TO none;
 CONFIGURE DEVICE TYPE 'SBT_TAPE' clear;


 restore database from service  $SRC_UNIQ section size 1G;
switch database to copy;

EOF

