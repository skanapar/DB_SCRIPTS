
#!/bin/bash
#
# Name:   set_dgbroker_apply.sh
# Version 1.0
# Modified: 07-FEB-2019
#Purpose:  Used to clone a  PDB over database link
# USAGE:  
# Dependencies:  Script framework,DB LINK matching the sourcedb name in the source container
# Modification Log:
 

usage() { echo "Usage: $0 -C container_name -s ON/OFF" 1>&2; exit 1; }

while getopts ":s:t:l:C:" o; do
    case "${o}" in
        C)
            CONTAINER_NAME=${OPTARG}
            ;;
        s)
            INTENDED_STATE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

set -x
if [[  -z ${CONTAINER_NAME}  ]]
then
usage
fi

if  ! [[ $INTENDED_STATE = "ON"   ||    $INTENDED_STATE = "OFF" ]]
then
 echo "value for -s ahould be ON/OFF"
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

get_wallet_pass DUMMY
exit_if_error $?
 
.  ~oracle/${CONTAINER_NAME}.env >/dev/null;

LCONTAINER_NAME=`echo $CONTAINER_NAME| awk ' {print tolower($0)}'`

dgmgrl  -echo <<EOF
connect /
show configuration
edit database '$LCONTAINER_NAME' set state='APPLY-$INTENDED_STATE';

EOF

echo script returned with  $?
