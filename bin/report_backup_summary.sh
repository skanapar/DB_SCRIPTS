
#!/bin/bash
#
# Name:   "report_backup_summary_daily.sh"
# Version 1.0
# Modified: 29-jan-2020
#Purpose:  connects to catalog database and runs summary report
# USAGE:run_all_peoplesoft_databases.sh sql_file
#       will pickup sql file from directory under ../sql directory if full path is not specified.
#       If Environment is configured then will use SQL file from env
# Dependencies:  Script framework,
# Modification Log:
 

usage() { echo "Usage: $0 -p catalog_pdb_name   -b days_back -C container_name" 1>&2; exit 1; }

while getopts ":p:b:C:" o; do
    case "${o}" in
        p)
            SOURCE_PDB_NAME=${OPTARG}
            ;;
        b)
            DAYS_BACK=${OPTARG}
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

if [[ -z ${SOURCE_PDB_NAME} || -z ${DAYS_BACK}|| -z ${CONTAINER_NAME}   ]]
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
BASE_SQL_DIR=$(dirname "$SQL_FILE")
if   [[ $BASE_SQL_DIR = "." ]]
then
SQL_FILE="${SQL_DIR}/${SQL_FILE}"
fi
REPORT_FILE=${REPORT_DIR}/RMAN_SUMMARY_REPORT_${TIMESTAMP}.lst
./run_sql_local_container_pluggable.sh NPMGM1C RMANNP1 report_backups.sql $REPORT_FILE $DAYS_BACK
cat ${REPORT_FILE}|mailx  -r  ${EMAIL_FROM} -s "RMAN REPORT for ${DAYS_BACK} days back run on ${HOSTNAME} - " ${EMAIL_DISTRIBUTION}
