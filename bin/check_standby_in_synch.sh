#!/bin/bash

usage() { echo "Usage: $0   -C container_name -p pdb_name  " 1>&2; exit 1; }

while getopts ":C:p:" o; do
    case "${o}" in
        C)
            CONTAINER_NAME=${OPTARG}
            ;;
        p)
            PDB_NAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[  -z ${CONTAINER_NAME} || -z ${PDB_NAME} ]]
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

LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER}_${LOG_SUFFIX}.log
echo $LOG_FILE
sleep 1
exec > >(tee -i ${LOG_FILE})
exec 2>&1
date


. /home/oracle/${CONTAINER_NAME}.env

exit_if_error $?

chk_interval=60
#
### sleep_interval - controls how long the script sleeps before rechecking the database
###                  to verify if the Logs Received and Applied sequence numbers are equal
###                - A value of 300, sleeps for 5 minutes.
###                - the value is in seconds
###
sleep_interval=300
#
#
v_flag=0
NOW=$TIMESTAMP
${BIN_DIR}/run_sql_local_container_pluggable.sh ${CONTAINER_NAME} ${PDB_NAME}  check_standby_in_sync.sql $NOW
exit


while [ ${v_flag} -lt 1 ]; do


  if [ "${v_utd}" = 'TRUE' ]; then
    v_flag=1
  fi

  x2nd_timestamp=$(date '+%m/%d/%Y %H:%M %Z' -d "${x1st_timestamp} + ${chk_interval} minutes")
  if [ "$(date '+%m/%d/%Y %H:%M %Z')" \> "${x2nd_timestamp}" ]; then
    email_body="## TEST ###\n\nProcess started - ${start_timestamp}\nCurrent time - ${x2nd_timestamp}\n\nLog Received - ${log_recvd}\nLog Applied  - ${log_applied}"
    email_subj="${ORACLE_SID} - Standby database log apply not completed."
    echo -e "${email_body}" | mailx -v -s "${email_subj}" ${v_email_to}
    x1st_timestamp=${x2nd_timestamp}
  fi

  sleep ${sleep_interval}

done
#
#


