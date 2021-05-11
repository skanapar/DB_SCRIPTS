#!/bin/bash
# This script is created on 19th April 2019
# This script creates the blackout window for the two MNT database
# The MNT database refresh start from 01:30AM to 6:00AM daily
# Script Name - oem_start_blackout_window.sh
#export AGENT_HOME=/u02/app/oracle/product/agent13c/agent_13.3.0.0.0
#export PATH=$PATH:$AGENT_HOME/bin
#export LOG=`date +"%b-%m-%d_%H_%M"`
#set -x
if [[ $# -ne 1 ]];
then
  echo " Argument:   Script need to pass database name as variable " 
  echo " Usage of script : sh oem_start_blackout_window.sh STSHMTCS.dbsts1.ACMEphx.oraclevcn.com_STSHMTCS1"

  exit 0;
fi


# Assign the passed database name to variable
export DBNAME=$1
echo $DBNAME
HOSTNAME=`hostname`
SUBJECT="${CLIENT}-DR : ${HOSTNAME} : OEM BLACKOUT WINDOW STARTING FOR MNT REFRESH "
EMAIL_LIST=""
FROM="oracle@ACME.accenture.com"

export AGENT_HOME=/u02/app/oracle/product/agent13c/agent_13.3.0.0.0
export PATH=$PATH:$AGENT_HOME/bin
export DT=`date +"%b-%m-%d_%H_%M"`
export LOG=/db_share/DBA/prod/scripts
export f2=$LOG/log/oem_balcakout_log_$DT.log

echo "Setting the blackout on instance 1"
#emctl start blackout blackout_STSHMTCS1 STSHMTCS.dbsts1.ACMEphx.oraclevcn.com_STSHMTCS1:oracle_database -d 10:00 >> $f2
#emctl start blackout blackout_STSFMTCS1 STSFMTCS.dbsts1.ACMEphx.oraclevcn.com_STSFMTCS1:oracle_database -d 10:00 >> $f2
echo "emctl start blackout blackout_STSFMTCS1 STSFMTCS.dbsts1.ACMEphx.oraclevcn.com_STSFMTCS1:oracle_database -d 10:00"

emctl status blackout >> $f2
echo "Setting the blackout on instance 2" >> $f2
#ssh sphx1-0icqc2 '/u02/app/oracle/product/agent13c/agent_13.3.0.0.0/bin/emctl start blackout  blackout_STSHMTCS2 STSHMTCS.dbsts1.ACMEphx.oraclevcn.com_STSHMTCS2:oracle_database -d 10:00' >> $f2
#ssh sphx1-0icqc2 '/u02/app/oracle/product/agent13c/agent_13.3.0.0.0/bin/emctl start blackout  blackout_STSFMTCS2 STSHMTCS.dbsts1.ACMEphx.oraclevcn.com_STSHMTCS2:oracle_database -d 10:00' >> $f2
echo "Blackout completed for both database" >> $f2
echo "Listing the blackout configured " >> $f2
#ssh sphx1-0icqc2 '/u02/app/oracle/product/agent13c/agent_13.3.0.0.0/bin/emctl status blackout' >> $f2


#Seding details on mail
#echo -e "Hi All, \n \nPFA See the attached logfile for MNT refresh oem snoozing "  | mailx -r $FROM -a $f2 -s "$SUBJECT" $EMAIL_LIST
