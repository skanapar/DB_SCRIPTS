#!/bin/bash
# This script is created on 19th April 2019
# This script creates the blackout window for the two MNT database 
# The MNT database refresh stop from 01:30AM to 6:00AM daily
export AGENT_HOME=/u02/app/oracle/product/agent13c/agent_13.3.0.0.0
export PATH=$PATH:$AGENT_HOME/bin
export DT=`date +"%b-%m-%d_%H_%M"`
#export LOG=/db_share/scripts/oem/
export LOG=/db_share/DBA/prod/scripts
export f2=$LOG/log/oem_blackout_stop_log$DT.log

set -x

HOSTNAME=`hostname`
SUBJECT="${CLIENT}-DR : ${HOSTNAME} : OEM BLACKOUT WINDOW STOPPING FOR MNT REFRESH "
EMAIL_LIST="XX@accenture.com"
FROM="oracle@ACME.accenture.com"


echo "Setting the blackout on instance 1" >> $f2
emctl stop blackout blackout_STSHMTCS1 >> $f2
emctl stop blackout blackout_STSFMTCS1 >> $f2
echo  " Listing existing blackout window on Server 1" >> $f2
emctl status blackout >> $f2
echo "Stopping blackout on instance 2" >> $f2
ssh sphx1-0icqc2 '/u02/app/oracle/product/agent13c/agent_13.3.0.0.0/bin/emctl stop blackout  blackout_STSHMTCS2' >> $f2
ssh sphx1-0icqc2 '/u02/app/oracle/product/agent13c/agent_13.3.0.0.0/bin/emctl stop blackout  blackout_STSFMTCS2' >> $f2
echo "Blackout removed for both database" >> $f2
echo  " Listing existing blackout window on Server 1" >> $f2
ssh sphx1-0icqc2 '/u02/app/oracle/product/agent13c/agent_13.3.0.0.0/bin/emctl status blackout' >> $f2

#Seding details on mail
echo -e "Hi All, \n \nPFA See the attached logfile for MNT refresh oem snoozing "  | mailx -r $FROM -a $f2 -s "$SUBJECT" $EMAIL_LIST

