#!/bin/bash
#
# Name:   common_functions.sh
# Version 1.0
# Modified: 12-Dec-2018
#Purpose:  Central location of all functions so code can be shared
# USAGE: N/A. Called internally by other scripts
# Dependencies:  Script framework
# Modification Log:

 

exit_if_error () {
if [[ $1 -ne 0 ]]
then
echo  -e $RED "Error: $*" $WHITE
exit -1
fi

}


#checks and returns if host is a RAC node or not. Y if rac node else N

is_this_host_a_rac_node () {
HOST_TYPE=`echo $HOSTNAME|cut -c5-7|tr \[a-z\] \[A-Z\]`

if [[ ${HOST_TYPE} = "RAC" ]]
then
  echo Y
else
   echo N
fi

}

#checks and returns if host is a RAC node or not. Y if rac node else N

 

get_all_nodes_this_cluster () {

HOST_NO_DOMAIN=`echo $HOSTNAME|cut -d "." -f1`
CLUSTER_NAME=`grep $HOST_NO_DOMAIN $CONFIG_DIR/server_list_all_rac_servers.lst|awk -F "," '{print $6}'`
cat  $CONFIG_DIR/server_list_all_rac_servers.lst|grep $CLUSTER_NAME|cut -d "," -f1

}

 

get_db_names_this_node () {
HOST_NO_DOMAIN=`echo $HOSTNAME|cut -d "." -f1`
. $CONFIG_DIR/set_environment_to_asm.env

for res_name in `crsctl stat res -w "TYPE = ora.database.type"|grep NAME|cut -c6-`
do
db_u_name=`crsctl stat res $res_name -p|grep DB_UNIQUE_NAME|cut -c16-`
#db_name=`echo $db_u_name|sed -e 's/_//gI' -e 's/_//gI'`
echo $db_name

done
 

}

get_wallet_pass () {
ID_TYPE=TDE
ENV=KEYSTORE
PASSPHRASE=""
WALLET_PASS=`openssl enc -aes-256-cbc -d -in ${KEY_STORE}  -pass pass:${PASSPHRASE} |grep "${ID_TYPE}:${ENV}" |cut -d":" -f3`
if [ -z "$WALLET_PASS" ] || [ "$WALLET_PASS" = ’’ ]
then
echo "PASSWORD IS NULL"
exit 1
fi

}

get_sys_pass () {
ID_TYPE=SYS
ENV=KEYSTORE
PASSPHRASE=""
SYS_PASS=`openssl enc -aes-256-cbc -d -in ${KEY_STORE}  -pass pass:${PASSPHRASE} |grep "${ID_TYPE}:${DB_NAME}" |cut -d":" -f3`
if [ -z "$SYS_PASS" ] || [ "$SYS_PASS" = ’’ ]
then
echo "PASSWORD IS NULL"
exit 1
fi

}
