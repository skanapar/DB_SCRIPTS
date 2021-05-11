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
SCRIPT_NAME="convert_snap_to_physical_standby.sh"
LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER}_${LOG_SUFFIX}.log
echo $LOG_FILE
sleep 1
exec > >(tee -i ${LOG_FILE})
exec 2>&1
date


. /home/oracle/${CONTAINER_NAME}.env
exit_if_error $?



if [ $? -ne 0 ]
then
echo "Unable to Set environment for $ORACLE_SID"
exit 3
fi
echo  running on $ORACLE_UNQNAME

set -x
DB_NAME=`echo $ORACLE_SID|rev|cut -c 2-|rev`
srvctl stop database -d $DB_NAME  -stopoption immediate


sqlplus  /nolog  <<EOF
connect / as sysdba
whenever sqlerror exit sql.sqlcode
whenever oserror exit failure

set termout on
set echo on
set feedback on

startup mount;
ALTER DATABASE CONVERT TO PHYSICAL STANDBY;

EOF
exit_if_error $?
echo "converted to Physical standby"

srvctl stop database -d $DB_NAME  -stopoption immediate
srvctl start database -d $DB_NAME -startoption open
exit_if_error $?

srvctl status database -d $DB_NAME

sqlplus  /nolog  <<EOF
connect / as sysdba

col db_unique_name format a15
col database_role format a25
col open_mode format a25
select db_unique_name, database_role, open_mode
from v\$database
/
show pdbs


EOF

####################### starting mrp just in case it did not started ##temporary fix
sqlplus  /nolog <<EOF
connect / as sysdba
set termout on
set echo on
alter system set dg_broker_start=true ;
host sleep 60
start ${SQL_DIR}/start_recovery.sql

EOF
exit

