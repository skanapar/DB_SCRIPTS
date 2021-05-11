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

shift $((OPTIND-1))

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
cp -p /acfs01/dbaas_acfs/${TARGET_CDB_NAME}/tde_wallet/ewallet.p12 /acfs01/dbaas_acfs/${TARGET_CDB_NAME}/tde_wallet/ewallet.${TIMESTAMP}.p12
exit_if_error $?
cp -p /acfs01/dbaas_acfs/${TARGET_CDB_NAME}/tde_wallet/cwallet.sso /acfs01/dbaas_acfs/${TARGET_CDB_NAME}/tde_wallet/cwallet.${TIMESTAMP}.sso
exit_if_error $?
scp  ${REMOTE_NODE}:/acfs01/dbaas_acfs/${SOURCE_CDB_NAME}/tde_wallet/ewallet.p12 /acfs01/dbaas_acfs/${TARGET_CDB_NAME}/tde_wallet/
scp  ${REMOTE_NODE}:/acfs01/dbaas_acfs/${SOURCE_CDB_NAME}/tde_wallet/cwallet.sso /acfs01/dbaas_acfs/${TARGET_CDB_NAME}/tde_wallet/



