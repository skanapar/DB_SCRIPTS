#!/bin/bash
#
# Name:   add_cdb_dg_tns.sh.sh
# Version 1.0
# Modified: 12-Dec-2016
#Purpose:  Adds DG tns
# USAGE:add_cdb_dg_tns.sh.sh 
#       will pickup sql file from directory under ../sql directory if full path is not specified.
#       If Environment is configured then will use SQL file from env
# Dependencies:  Script framework,
# Modification Log:

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

SRC_UNIQ=`ssh ${REMOTE_NODE} cat ~oracle/${SOURCE_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`

BACKUP_TGT=/db_share/DG/pwfile_${TARGET_CDB_NAME}
BACKUP_SRC=/db_share/DG/pwfile_${SOURCE_CDB_NAME}
ssh ${REMOTE_NODE} " . ${SOURCE_CDB_NAME}.env; asmcmd --privilege sysdba pwcopy  +DATAC1/${SRC_UNIQ}/PASSWORD/passwd ${BACKUP_SRC}"
ssh ${REMOTE_NODE} " ls -lrt ${BACKUP_SRC}"
scp ${REMOTE_NODE}:${BACKUP_SRC} ${BACKUP_TGT}

. ~/${TARGET_CDB_NAME}.env

set -x
asmcmd --privilege sysdba pwcopy ${BACKUP_TGT} +DATAC1/${ORACLE_UNQNAME}/PASSWORD/passwd
#orapwd file=+datac1 dbuniquename=${ORACLE_UNQNAME} input_file=${BACKUP_TGT}

cp  ${BACKUP_TGT} ${ORACLE_HOME}/dbs/orapw${ORACLE_SID}

