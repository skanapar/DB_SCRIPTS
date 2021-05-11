#!/bin/bash

usage() { echo "Usage: $0  -i input_file -o output_file -p PASS_PHRASE " 1>&2; exit 1; }

while getopts ":i:o:p:" o; do
    case "${o}" in
        i)
            INPUT_FILE=${OPTARG}
            ;;
        o)
            OUTPUT_FILE=${OPTARG}
            ;;
        p)
            PASS_PHRASE=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[  -z ${INPUT_FILE} ||  -z ${PASS_PHRASE} || -z ${OUTPUT_FILE} ]]
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

#
source $BASE_DIR/common_functions.sh
exit_if_error $?

echo openssl enc -aes-256-cbc -e -in ${INPUT_FILE} -pass pass:${PASS_PHRASE} ${OUTPUT_FILE}
openssl enc -aes-256-cbc -e -in ${INPUT_FILE} -pass pass:${PASS_PHRASE} > ${OUTPUT_FILE}


exit_if_error $?

echo "end"
