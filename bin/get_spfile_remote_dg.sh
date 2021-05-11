#!/bin/bash
#
# Name:   get_spfile_remote_dg.sh
# Version 1.0
# Modified: 12-Dec-2019
#Purpose:  get_spfile_remote_dg.sh
# USAGE:a get_spfile_remote_dg.sh
#       will pickup sql file from directory under ../sql directory if full path is not specified.
#       If Environment is configured then will use SQL file from env
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
BACKUP1=/db_share/DG/spfile_${TARGET_CDB_NAME}_${TIMESTAMP}_TGT
BACKUP_TGT=/db_share/DG/spfile_${TARGET_CDB_NAME}_TGT
${BIN_DIR}/run_sql_local.sh ${ORACLE_SID} backup_spfile.sql $BACKUP1
exit_if_error $?
cat ${BACKUP1}| egrep 'cluster_interconnects|control_files|db_domain|remote_listener|log_archive_dest|db_unique_name|dispatchers' >${BACKUP_TGT}

BACKUP_SRC=/db_share/DG/spfile_${SOURCE_CDB_NAME}_src
set -x
ssh ${REMOTE_NODE} " ${BIN_DIR}/run_sql_local_container.sh ${SOURCE_CDB_NAME} backup_spfile.sql $BACKUP_SRC"
scp ${REMOTE_NODE}:${BACKUP_SRC} /db_share/DG
cat ${BACKUP_SRC}|grep -v cluster_interconnects|grep -v control_files|grep -v db_domain|grep -v remote_listener|grep -v log_archive_dest|\
                 grep -v db_unique_name|grep -v "__"|grep -v dispatchers|sed -e "s/^${SOURCE_CDB_NAME}/${TARGET_CDB_NAME}/g"\
                |grep -v name_convert >>${BACKUP_TGT}
#diff ${BACKUP1} ${BACKUP_TGT}


SRC_UNIQ=`ssh ${REMOTE_NODE} cat ~oracle/${SOURCE_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
TGT_UNIQ=` cat ~oracle/${TARGET_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
TGT_DB_NAME=`echo $TGT_UNIQ|cut -d"_" -f1`
DB_NAME=`echo $SRC_UNIQ|cut -d"_" -f1`
echo "log_file_name_convert=""'"$SRC_UNIQ"'","'"$TGT_UNIQ"'" >>${BACKUP_TGT}
echo "db_file_name_convert=""'"$SRC_UNIQ"'","'"$TGT_UNIQ"'" >>${BACKUP_TGT}

cat ${BACKUP_TGT}



exit





