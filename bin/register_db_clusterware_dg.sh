#!/bin/bash
#
# Name:  register_db_clusterware.sh
# Version 1.0
# Modified: 12-Dec-2019
#Purpose: Registers database with clusterware
# USAGE: register_db_clusterware_dg.sh CONTAINER 
# Dependencies:  Script framework
# Modification Log:

usage() { echo "Usage: $0  -t target_cdb_name  " 1>&2; exit 1; }

while getopts ":t:" o; do
    case "${o}" in
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

if [[ -z ${TARGET_CDB_NAME} ]]
then
usage
fi
CONTAINER=${TARGET_CDB_NAME};

BASE_DIR=$(dirname "$0"); export BASE_DIR
SCRIPT_NAME=$(basename "$0"); export SCRIPT_NAME
sql_file=$(basename "$2"); export sql_file

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

LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER}_${sql_file}_${LOG_SUFFIX}.log
echo $LOG_FILE
sleep 1
exec > >(tee -i ${LOG_FILE})
exec 2>&1
date 


 . ${BASE_DIR}/../config/set_environme*asm*env
HOSTS=`olsnodes`
echo $HOSTS
. ~oracle/${CONTAINER}.env >/dev/null;
if [ $? -ne 0 ]
then
echo "Unable to Set environment for $ORACLE_SID"
exit 3
fi


SPFILE="+DATAC1/${ORACLE_UNQNAME}/spfile${CONTAINER}.ora"
DB_NAME=$CONTAINER
if [[ $HOST == "pr"* ]]
then
echo "running on prod"
local_scan=$ASH_SCAN
remote_scan=$PHX_SCAN
local_suffix=$ASH_DOMAIN
remote_suffix=$PHX_DOMAIN
else
echo "running on non-prod"
local_scan=$PHX_SCAN
remote_scan=$ASH_SCAN
local_suffix=$PHX_DOMAIN
remote_suffix=$ASH_DOMAIN
fi


echo "srvctl add database -db $ORACLE_UNQNAME -oraclehome $ORACLE_HOME -dbtype RAC \
      -domain $local_suffix -dbname $DB_NAME -startoption open \
-spfile $SPFILE \
-pwfile +DATAC1/$ORACLE_UNQNAME/PASSWORD/passwd \
 -role PHYSICAL_STANDBY -diskgroup DATAC1 \
"
srvctl add database -db $ORACLE_UNQNAME -oraclehome $ORACLE_HOME -dbtype RAC \
      -domain $local_suffix -dbname $DB_NAME -startoption open \
-spfile $SPFILE \
 -role PHYSICAL_STANDBY -diskgroup DATAC1 \
-pwfile +DATAC1/$ORACLE_UNQNAME/PASSWORD/passwd 

for host in $HOSTS 
do
node_suffix=`echo $host|rev|cut -c1`
echo srvctl add instance -db $ORACLE_UNQNAME -instance ${CONTAINER}${node_suffix} -node $host
srvctl add instance -db $ORACLE_UNQNAME -instance ${CONTAINER}${node_suffix} -node $host
done

