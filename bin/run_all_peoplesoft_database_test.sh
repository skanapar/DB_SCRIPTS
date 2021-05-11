
#!/bin/bash
#
# Name:   run_sql_all_instances_local_node.sh
# Version 1.0
# Modified: 12-Dec-2016
#Purpose:  Runs a sql script on all instances of this nodes excluding ASM and MGMT DB
# USAGE:run_sql_all_instances_local_node.sh sql_file
#       will pickup sql file from directory under ../sql directory if full path is not specified.
#       If Environment is configured then will use SQL file from env
# Dependencies:  Script framework,
# Modification Log:
 
 
if (( $# < 1 ))
then
  echo " Argument: SQL_FILE Expected "
fi
SQL_FILE=$1
 
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
 
for rec in `ps -ef|grep pmon|grep -v grep | grep -v perl| grep -v ASM|grep -v APX|awk '{print $8}'`
do
 
        str_length=${#rec}
        str_to_cut="ora_pmon_"
        #ORACLE_SID=${rec:${#str_to_cut}-1:$str_length-1}
        ORACLE_SID=${rec:9:$str_length-1}
        ORACLE_SID=`echo $rec|cut -c10-18`
        DB_NAME=`echo $ORACLE_SID|rev|cut -c 2-|rev`
              . ~oracle/${DB_NAME}.env >/dev/null;

#        echo $ORACLE_SID
# $ORACLE_HOME//perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -d $PWD  -b test -l $LOG_DIR  $SQL_FILE
#   ${BIN_DIR}/run_sql_local.sh  $ORACLE_SID $SQL_FILE
PDBS=`${BIN_DIR}/get_psoft_pdbs.sh|grep -v "^#"|grep -v SEED`

for pdb in $PDBS
do
echo PDB is $pdb sql_file is $SQL_FILE
sqlplus  -s "/as sysdba" <<EOF
alter session set container=$pdb
/
start ${SQL_FILE}
EOF

done

 
done
