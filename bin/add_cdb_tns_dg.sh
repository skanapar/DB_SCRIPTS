#!/bin/bash
#
# Name:   add_cdb_dg_tns.sh.sh
# Version 1.0
# Modified: 12-Dec-2019
#Purpose:  Adds DG tns
# USAGE:add_cdb_dg_tns.sh.sh
# Dependencies:  Script framework,
# Modification Log:
BASE_DIR=$(dirname "$0"); export BASE_DIR

usage() { echo "Usage: $0 -s source_cdb_name  -t target_cdb_name  -r REMOTE_NODE " 1>&2; exit 1; }

while getopts ":s:t:r:" o; do
    case "${o}" in
        s)
            SOURCE_CDB_NAME=${OPTARG}
            ;;
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

if [[ -z ${SOURCE_CDB_NAME} || -z ${TARGET_CDB_NAME} || -z ${REMOTE_NODE} ]]
then
usage
fi

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
for  ORACLE_UNQNAME in `grep UNQ ~/*.env|cut -d";" -f1|cut -d "=" -f2`
do
if grep -q $ORACLE_UNQNAME /etc/oratab
then
    echo  $ORACLE_UNQNAME found in /etc/oratab
else
    echo   $ORACLE_UNQNAME:$ORACLE_HOME:Y>>/etc/oratab
fi
done
for DB_NAME in `cat /etc/oratab|grep -v "^#"|cut -d":" -f1 |cut -d"_" -f1 |grep $TARGET_CDB_NAME `
do
echo $DB_NAME

PR_UNIQ=` cat ~oracle/${DB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`
DR_DB_NAME=$TARGET_CDB_NAME
DR_UNIQ=`ssh ${REMOTE_NODE} cat ~oracle/${SOURCE_CDB_NAME}.env|grep UNQ|cut -d";" -f1|cut -d "=" -f2`


. ~oracle/${DB_NAME}.env >/dev/null;




exit_if_error $?
echo "PR_UNIQ is $PR_UNIQ, DR_UNIQ is $DR_UNIQ"
TNS_FILE=$ORACLE_HOME/network/admin/${DB_NAME}/tnsnames.ora
SQLNET_FILE=$ORACLE_HOME/network/admin/${DB_NAME}/sqlnet.ora
echo $TNS_FILE
  if grep  -q "^$PR_UNIQ"  $TNS_FILE
  then
    echo "$PR_UNIQ found"
    else
        echo $PR_UNIQ not found
          cp -p $TNS_FILE $ORACLE_HOME/network/admin/${DB_NAME}/tnsnames.ora.${TIMESTAMP}
            sleep 1
echo "$PR_UNIQ =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $LOCAL_SCAN)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${PR_UNIQ}.${LOCAL_SUFFIX})
    )
  )" >>$TNS_FILE
fi
 grep -q  "^$PR_UNIQ"  $TNS_FILE
tnsping  $PR_UNIQ
      sleep 2
if grep  -q "^$DR_UNIQ"  $TNS_FILE
  then
    echo "$DR_UNIQ found"
    else
        echo $DR_UNIQ not found
          cp -p $TNS_FILE $ORACLE_HOME/network/admin/${DB_NAME}/tnsnames.ora.${TIMESTAMP}
            sleep 5
echo "$DR_UNIQ =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $REMOTE_SCAN)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ${DR_UNIQ}.${REMOTE_SUFFIX})
    )
  )" >>$TNS_FILE
fi
 grep   $DR_UNIQ  $TNS_FILE
tnsping  $DR_UNIQ
      sleep 2
if [ ! -f $ORACLE_HOME/network/admin/tnsnames.ora ]
then
ln -s  ${TNS_FILE} $ORACLE_HOME/network/admin/tnsnames.ora
fi
if [ ! -f $ORACLE_HOME/network/admin/sqlnet.ora ]
then
ln -s  ${SQLNET_FILE} $ORACLE_HOME/network/admin/sqlnet.ora
fi


done
