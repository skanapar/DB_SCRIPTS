#!/bin/bash
#
# Name:   run_sql_local.sh
# Version 1.0
# Modified: 12-Dec-2016
#Purpose:  runs a sql script locally on this node
# USAGE: run_sql_local.sh ORACLE_SID SQL_FILE
# Dependencies:  Script framework, get_database_instances_running_this_node.sh, get_listeners_running_this_node.sh
# Modification Log:


if (( $# < 2 ))
then
  echo " Argument:  SID  & SQL_FILE Expected "
fi

 

ORACLE_SID=$1;
SQL_FILE=$2
DB_NAME=`echo $ORACLE_SID|rev|cut -c 2-|rev`

. ~oracle/${DB_NAME}.env >/dev/null;
if [ $? -ne 0 ]
then
echo "Unable to Set environment for $ORACLE_SID"
exit 3
fi
sqlplus  -s "/as sysdba" <<EOF
start ${SQL_FILE} $3 $4
EOF
