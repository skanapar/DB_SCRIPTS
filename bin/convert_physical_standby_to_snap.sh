#!/bin/bash




usage() { echo "Usage: $0   -C container_name" 1>&2; exit 1; }

while getopts ":C:" o; do
    case "${o}" in
        C)
            CONTAINER_NAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[  -z ${CONTAINER_NAME}  ]]
then
usage
fi

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

#
source $BASE_DIR/common_functions.sh
exit_if_error $?
SCRIPT_NAME="convert_physical_standby_to_snap.sh"
LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER}_${LOG_SUFFIX}.log
echo $LOG_FILE
sleep 1
exec > >(tee -i ${LOG_FILE})
2>&1
date


. /home/oracle/${CONTAINER_NAME}.env
exit_if_error $?
set -x


if [ $? -ne 0 ]
then
echo "Unable to Set environment for $DB_NAME"
exit 3
fi
echo  running on $ORACLE_UNQNAME
sqlplus  /nolog <<EOF
connect / as sysdba
set termout on
set echo on
set feedback on
alter system set dg_broker_start=false;
alter database recover managed standby database cancel;
whenever sqlerror exit sql.sqlcode
whenever oserror exit failure
alter database convert to snapshot standby;

EOF
exit_if_error $?

echo "converted to snap"

DB_NAME=`echo $ORACLE_SID|rev|cut -c 2-|rev`
echo "bouncing db $DB_NAME"
srvctl stop database -d $DB_NAME   -stopoption immediate
srvctl start database -d $DB_NAME -startoption open
srvctl status database -d $DB_NAME

sqlplus  /nolog <<EOF
connect / as sysdba
set termout on
set echo on
set feedback on
col db_unique_name format a15
col database_role format a25
col open_mode format a25
select db_unique_name, database_role, open_mode
from v\$database
/
show pdbs

EOF

