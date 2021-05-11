#!/bin/bash



usage() { echo "Usage: $0  -p pdb_name   -C container_name" 1>&2; exit 1; }

while getopts ":p:C:" o; do
    case "${o}" in
        p)
            PDB_NAME=${OPTARG}
            ;;
        C)
            CONTAINER_NAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[  -z ${PDB_NAME}|| -z ${CONTAINER_NAME}  ]]
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
exit_if_error $?

#
source $BASE_DIR/common_functions.sh
exit_if_error $?

. /home/oracle/${CONTAINER_NAME}.env
exit_if_error $?


echo  running on $PDB_NAME
${BIN_DIR}/run_sql_local.sh  ${ORACLE_SID} ${SQL_DIR}/psu_oct2018_pdb_1.sql  $PDB_NAME
exit_if_error $?
datapatch
datapatch
${BIN_DIR}/run_sql_local.sh  ${ORACLE_SID} ${SQL_DIR}/reopen_pdb.sql  $PDB_NAME
exit_if_error $?



echo "################################################################################"
echo "  checking dbservices are up "
echo "################################################################################"

DB_NAME=`echo $ORACLE_SID|rev|cut -c2-|rev`
srvctl start service -d $DB_NAME
srvctl status service -d $DB_NAME






