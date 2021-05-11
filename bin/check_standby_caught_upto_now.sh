#!/bin/bash
usage(){
  echo
  echo ----------------------------------------------------------
  echo ----------------------------------------------------------
  echo
  echo
  echo '  Script has two positional parameters:'
  echo
  echo '  #1  Container database name(the value from /etc/oratab)'
  echo '  #2  PDB name'
  echo
  echo '  Example:   chk_lag.sh -C STSHMTCS -p HCMMNT1'
  echo
  echo
  echo ----------------------------------------------------------
  echo ----------------------------------------------------------
  echo
}

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

if [[  -z ${CONTAINER_NAME} || -z ${PDB_NAME} ]]; then
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



#
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${ORACLE_HOME}/bin
. /home/oracle/${CONTAINER_NAME}.env

SCRIPT_NAME="check_standby_caught_upto_now.sh"
LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER_NAME}_${LOG_SUFFIX}.log
exec > >(tee -i ${LOG_FILE})
exec 2>&1

echo "LOGFILE is $LOG_FILE "
###  validate the Standby database to ensure it has the role 'PHYSICAL STANDBY'
export v_tmp_log=$(mktemp)
${ORACLE_HOME}/bin/sqlplus -s  << EOF
conn / as sysdba
set termout off
whenever sqlerror exit sql.sqlcode
whenever oserror exit failure
alter session set container=${PDB_NAME}
/
set pages 0 feed off trims on
spool ${v_tmp_log}
select trim(database_role) from v\$database
/
spool off
EOF
if [ "$?" -gt 0 ]; then
  echo 'SQL Plus error.  Standby database role.  Exit script.'
  exit 9
fi
#
export v_db_role=`cat ${v_tmp_log}`
if [ "${v_db_role}" != 'PHYSICAL STANDBY' ]; then
  echo 'Standby Database Role is not PHYSICAL STANDBY'
  exit 9
fi
#
export v_host=`hostname -s`
export v_tmstamp_0=`date +%Z_%Y%m%d_%a_%H%M%S`
export v_sh_exec=`readlink -f "$0"`
export v_absolute_path=$(dirname `readlink -f "$0"` )
export v_sh_name=`basename "${0%.*}"`
export v_parms_passed=${@}
export v_email_to='XXXc@accenture.com'
#
export sql_dir=/mnt/db_share_prim/DBA/prod/scripts/sql
v_flag=0
#
start_timestamp=$(date '+%m/%d/%Y %H:%M %Z')
x1st_timestamp="${start_timestamp}"
current_timestamp=$(date '+%Y%m%d_%H%M%S')
v_count=0
#
### chk_interval - controls how frequent a Run Status email is sent
###              - used for long script execution times
###              - Example: if the script runs for more than 60 minutes and has not completed,
###                Send a Run Status email
###              - the value is in minutes
###
chk_interval=45
#
### sleep_interval - controls how long the script sleeps before rechecking the database
###                  to verify if the Logs Received and Applied sequence numbers are equal
###                - A value of 300, sleeps for 5 minutes.
###                - the value is in seconds
###
#sleep_interval=180
sleep_interval=180
#
#
while [ "${v_flag}" -lt 1 ]; do

${ORACLE_HOME}/bin/sqlplus -s  << EOF
conn / as sysdba
set termout on
whenever sqlerror exit sql.sqlcode
whenever oserror exit failure
--alter session set container=${PDB_NAME}
--/
spool ${v_tmp_log}
start ${sql_dir}/start_recovery.sql -- Temporary bandaid as MRP was dying for STSHMTCS
@${sql_dir}/csis.sql ${current_timestamp}
spool off
EOF
  if [ "$?" -gt 0 ]; then
    echo 'SQL Plus error.  Exit script.'
    exit 3
  fi

  v_utd=`cat ${v_tmp_log}`
  if [ "${v_utd}" = '#YES#' ]; then
    v_flag=1
  else
    x2nd_timestamp=$(date '+%m/%d/%Y %H:%M %Z' -d "${x1st_timestamp} + ${chk_interval} minutes")
    if [ "$(date '+%m/%d/%Y %H:%M %Z')" \> "${x2nd_timestamp}" ]; then
      email_body="\nProcess started - ${start_timestamp}\nCurrent time - ${x2nd_timestamp}\n\n"
      email_subj="${ORACLE_SID} - Standby database apply lag is not up to date."
###    echo -e "${email_body}" | mailx -v -s "${email_subj}" ${v_email_to}
      x1st_timestamp=${x2nd_timestamp}
    fi

    sleep ${sleep_interval}
  fi

done
#
#
