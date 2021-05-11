
#!/bin/bash
#
# Name:   dg_switchover.sh
# Version 1.0
# Modified: 03-FEB-2020
#Purpose:  Perform Switchover.sh
# USAGE:  
# Dependencies:  Script framework
# Modification Log:
 

usage() { echo "Usage: $0 -C container_name -t ASHBURN/PHOENIX" 1>&2; exit 1; }

while getopts ":s:t:l:C:" o; do
    case "${o}" in
        C)
            CONTAINER_NAME=${OPTARG}
            ;;
        t)
           TARGET_PRIMARY=${OPTARG}
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

if  ! [[ $TARGET_PRIMARY = "ASHBURN"   ||    $TARGET_PRIMARY = "PHOENIX" ]]
then
 echo "value for -t should be ASHBURN/PHOENIX"
 exit
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
exit_if_error $?

DB_NAME=${CONTAINER_NAME}; export DB_NAME
get_sys_pass DUMMY
exit_if_error $?
.  ~oracle/${CONTAINER_NAME}.env >/dev/null;
echo SYS_PASSWORD is $SYS_PASS
LCONTAINER_NAME=`echo $CONTAINER_NAME| awk ' {print tolower($0)}'`
DGMGRL_LOG=${LOG_DIR}/dgmgrl_${CONTAINER_NAME}_${LOG_SUFFIX}.log

dgmgrl -logfile ${DGMGRL_LOG}  / "show configuration ;"
exit_if_error $?
PHOENIX_UNIQ=`cat $DGMGRL_LOG|grep -A3 Members| grep "_phx"|awk '{print $1}'`
ASHBURN_UNIQ=`cat $DGMGRL_LOG|grep -A3 Members|grep "_iad"|awk '{print $1}'`

if [[ $TARGET_PRIMARY = "ASHBURN" ]]
then
TARGET_UNIQ=$ASHBURN_UNIQ
else
TARGET_UNIQ=$PHOENIX_UNIQ
fi


DG_STATUS=`cat $DGMGRL_LOG|grep -A1 "Configuration Status"|grep -v "Configuration Status"|awk '{print $1}'`

echo Phoenix UNIQ is  $PHOENIX_UNIQ Ashburn Uniq is $ASHBURN_UNIQ  DG_STATUS is ${DG_STATUS}
if  ! [[ $DG_STATUS = "SUCCESS" ]]
then
  echo "Error: Data Guard status is $DG_STATUS "
  exit 99
fi

echo " preparing to do a switchover to TARGET_UNIQ $TARGET_UNIQ"
sleep 5

dgmgrl <<EOF
connect sys/$SYS_PASS
show configuration;
switchover to ${TARGET_UNIQ}
exit;

EOF




