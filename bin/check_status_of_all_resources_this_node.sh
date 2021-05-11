#!/bin/bash
#
# Name:   check_status_of_all_oracle_resources_this_node.sh
# Version 1.0
# Modified: 12-Dec-2016
#Purpose:  Checks if all the resources that are supposed to be running are up. If -r Y  is specificed then down services are attempted to be restarted
# USAGE:check_database_listener_registered_with_crs.sh  [-r Y]
# Dependencies:  Script framework
# Modification Log:

set -o pipefail

usage() { echo "Usage: $0 [-r ]  " 1>&2; exit 1; }
RESTART_SERVICES=N
while getopts "r" o; do
    case "${o}" in
        r)
            RESTART_SERVICES=Y
            ;;
      
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))
###########Common env setup Code##############
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
exit_if_error $?
###########Common env setup Code##############

RAC_NODE=`is_this_host_a_rac_node`

if grep -q "+ASM" /etc/oratab
then
  . ${BASE_DIR}/../config/set_environment_to_asm.env
    CRS_REPORT=`crsctl status res |grep -v "^$"|awk -F "=" 'BEGIN {print " "} {printf("%s",NR%4 ? $2"|" : $2"\n")}'|sed -e 's/ *, /,/g' -e 's/, /,/g' | \
                 awk -F "|" 'BEGIN { }{ split ($3,trg,",") split ($4,st,",")}{for (i in trg) {printf "%-40s%-35s%-20s%-50s\n",$1,$2,trg[i],st[i]}}'|sort -r -k4`
     
    exit_if_error $? "Unable to run crsctl command Oracle Restart/clusterare are down***** \n  Use start_stop_oracle_services.sh script to restart Oracle HAS/CRS \n"
   # try and restart any databases  listeners  or servcies that are down
   if [[ $RESTART_SERVICES = "Y" ]]
   then
      while read  res 
      do
            RES_NAME=`echo $res|awk '{print $1}'`
            if echo "$res"|grep -q ora.service.type
            then
              SERVICE_NAME=`echo $RES_NAME|cut -d"." -f3`
              DB_UNIQ=`echo $RES_NAME|cut -d"." -f2`
                ORACLE_HOME=`crsctl stat res ora.${DB_UNIQ}.db -p|grep ORACLE_HOME|grep -v ORACLE_HOME_OLD|cut -d"=" -f2`
              echo "SERVCIENAME $RES_NAME is down"
             # echo "$ORACLE_HOME/bin/srvctl start service  -d $DB_UNIQ -s $SERVICE_NAME"
              $ORACLE_HOME/bin/srvctl start service  -d $DB_UNIQ -s $SERVICE_NAME
            fi
            ORACLE_HOME=`crsctl stat res $RES_NAME -p|grep ORACLE_HOME|cut -d"=" -f2`
            #crsctl stat res $RES_NAME -p
            DB_UNIQ=`crsctl stat res $RES_NAME -p|grep "^DB_UNIQ"|cut -d"=" -f2`
            #crsctl stat res $RES_NAME -p|grep "^DB_UNIQ"
            if echo "$res" |grep -q ora.database.type
            then
              echo "Database $RES_NAME res is down "
              echo "$ORACLE_HOME/bin/srvctl start database -d $DB_UNIQ"
              $ORACLE_HOME/bin/srvctl start database -d $DB_UNIQ
             fi
            if echo "$res"|grep -q ora.listener.type
            then
              LISTENER_NAME=`echo $RES_NAME|cut -d"." -f2`
              echo "listener $LISTENER_NAME is down"
              $ORACLE_HOME/bin/srvctl start listener -l $LISTENER_NAME
            fi
      done< <(echo "$CRS_REPORT"|grep OFFLINE|grep -e "ora.database.type\|ora.listener.type\|ora.service.type"|\
                 sort -k2)
                #grep  -v adwprd_wdc| grep  -v  -q  bip_wdc | grep -v "_gg.svc" \
    CRS_REPORT=`crsctl status res |grep -v "^$"|awk -F "=" 'BEGIN {print " "} {printf("%s",NR%4 ? $2"|" : $2"\n")}'|sed -e 's/ *, /,/g' -e 's/, /,/g' | \
                 awk -F "|" 'BEGIN { }{ split ($3,trg,",") split ($4,st,",")}{for (i in trg) {printf "%-40s%-35s%-20s%-50s\n",$1,$2,trg[i],st[i]}}'|sort -r -k4`
   fi
   if [[ -z $CRS_REPORT ]]
   then
     printf  "%b%s%b\n"  $RED  " NO ORACLE PROCESSES RUNNING on $HOSTNAME ****  <-- Needs Attention " $WHITE
     exit 1
   else
     printf "%-40s%-35s%-20s%-50s\n" "Resource Name" "Resource Type" "Target " "State" 
     printf "%-40s%-35s%-20s%-50s\n" "-------------" "-------------" "------ " "-----" 
       while read line 
       do
          if ! echo $line|awk '{print $4}' |grep -q ONLINE
          ##if   echo $line | grep  -v adwprd_wdc| grep  -v  -q  bip_wdc | grep -v "_gg.svc" && #exception for BIP & ADW whose ADG is not working 
               ##! echo $line| awk '{print $4}' |grep -q ONLINE  
          then
             if [[ $RAC_NODE = "Y" ]]
             then
                printf  "%b%s%b\n"  $RED  "$line    <--- Needs Attention" $WHITE
             else
                if ! echo $line|grep -e "ora.diskmon\|ora.ons" >/dev/null
                then
                     printf  "%b%s%b\n"  $RED  "$line  <-- Needs Attention" $WHITE
                fi   
              fi
           else
             printf  "%b%s%b\n"  $GREEN  "$line " $WHITE
           fi

            
        done < <(echo "$CRS_REPORT")
   fi
else
#One off check for databases not using ASM
  echo "NO CRS or HAS in use -- checking for resources starting up through custom scripts "
  ORATAB=`cat /etc/oratab|grep -v "^#" |grep -v LSNR|grep -v GCAGENT|grep ":" |grep -v oms|grep -v agent`
   while read  line 
   do
      DB_NAME=`echo $line|cut -d ":" -f1`
      echo "checking database $DB_NAME"
       if ps -ef|grep pmon|grep -q $DB_NAME
       then
           printf  "%b%s%b\n"  $GREEN  "Database $DB_NAME is up " $WHITE
       else 
           printf  "%b%s%b\n"  $RED  "Database $DB_NAME is down  <--- Needs Attention" $WHITE
        fi
    done < <(echo -e "$ORATAB")
  ORATAB=`cat /etc/oratab|grep -v "^#" |grep  LSNR`
   while read  line 
   do
      LSNR_NAME=`echo $line|cut -d ":" -f1`
      echo "checking LISTENER $LSNR_NAME"
       if ps -ef|grep pmon|grep -q $DB_NAME
       then
           printf  "%b%s%b\n"  $GREEN  "Listener $LSNR_NAME is up " $WHITE
       else 
           printf  "%b%s%b\n"  $RED  "Listener $LSNR_NAME is down  <--- Needs Attention" $WHITE
        fi
    done < <(echo -e "$ORATAB")
fi

