#set -x
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
  echo '  Example:   chk_lag.sh STSHMTCS HCMMNT1'
  echo
  echo
  echo ----------------------------------------------------------
  echo ----------------------------------------------------------
  echo
}

#####  If no arguments are entered, then echo how the script should be executed
if [ $# -lt 2  ]; then
  usage
  exit 1
fi
#
export ORACLE_SID=$1
chk_value=`cat /etc/oratab|grep ${ORACLE_SID}`
v_RC=$?
if [ ${v_RC} != 0 ]; then
  echo "!! Value passed for ${ORACLE_SID} was not found in /etc/oratab"
  exit 1
fi
export CON_NAME=$2
export ORACLE_HOME=`cat /etc/oratab|grep ${ORACLE_SID}|awk -F: '{print $2;}'`
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:${ORACLE_HOME}/bin
export ORACLE_BASE=/u02/app/oracle
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib


export v_host=`hostname -s`
export v_tmstamp_0=`date +%Z_%Y%m%d_%a_%H%M%S`
export v_sh_exec=`readlink -f "$0"`
export v_absolute_path=$(dirname `readlink -f "$0"` )
export v_sh_name=`basename "${0%.*}"`
export v_parms_passed=${@}
export v_email_to='scott.tudor@accenture.com'
#
###  reset ORACLE_SID value for Standby instance
export ORACLE_SID=${ORACLE_SID}2
export sql_dir=${v_absolute_path}
export v_tmp_log=$(mktemp)
v_flag=0
#

exit

#
start_timestamp=$(date '+%m/%d/%Y %H:%M %Z')
x1st_timestamp="${start_timestamp}"
v_count=0
#
### chk_interval - controls how frequent a Run Status email is sent
###              - used for long script execution times
###              - Example: if the script runs for more than 60 minutes and has not completed,
###                Send a Run Status email
###              - the value is in minutes
###
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
while [ ${v_flag} -lt 1 ]; do

${ORACLE_HOME}/bin/sqlplus -s  << EOF
conn / as sysdba
alter session set container=${CON_NAME}
/
spool ${v_tmp_log}
@${sql_dir}/lag2.sql
spool off
EOF

  v_utd=`cat ${v_tmp_log} | awk '{print $7}'`
  log_applied=`cat ${v_tmp_log} | awk '{print $5}'`
  log_recvd=`cat ${v_tmp_log} | awk '{print $4}'`
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
