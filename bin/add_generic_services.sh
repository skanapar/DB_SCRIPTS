#!/bin/bash



usage() { echo "Usage: $0   -C container_name" 1>&2; exit 1; }

while getopts ":C:" o; do
    case "${o}" in
        C)
            CONTAINER_NAME=${OPTARG}
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

LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${CONTAINER}_${LOG_SUFFIX}.log
echo $LOG_FILE
sleep 1
exec > >(tee -i ${LOG_FILE})
2>&1
date


. /home/oracle/${CONTAINER_NAME}.env
exit_if_error $?


SPOOL_FILE="/tmp/add_service_$$PID.lst"
echo $SPOOL_FILE
sqlplus -s "/as sysdba" <<EOF
show pdbs
set linesize 300
set heading off
set feedback off
set echo off
spool $SPOOL_FILE
select  'srvctl add service -d '|| d.db_unique_name|| ' -s '||p.name||'.ACME.accenture.com -pdb '||p.name ||' -preferred '||d.db_unique_name||'1,'|| d.db_unique_name||'2' ||' -role primary'
from  v\$database d, v\$pdbs p
where p.con_id >1
and p.name <>'PDB\$SEED'
and p.name not like '%JUNK%'
union
select  'srvctl add service -d '|| d.db_unique_name|| ' -s '||p.name||'_DBFS.ACME.accenture.com -pdb '||p.name ||' -preferred '||d.db_unique_name||'1,'|| d.db_unique_name||'2' || ' -role primary'
from  v\$database d, v\$pdbs p
where p.con_id >1
and p.name <>'PDB\$SEED'
and p.name in ('FINPRD1', 'HCMPRD1', 'FINUAT1', 'HCMUAT1', 'FINUAT3','HCMUAT3')
and p.name not like '%JUNK%'
union
select  'srvctl add service -d '|| d.db_unique_name|| ' -s '||d.name||'_GG.ACME.accenture.com  -preferred '||d.db_unique_name||'1,'|| d.db_unique_name||'2' ||' -role primary'
from  v\$database d
where  exists (
select 1
from v\$pdbs p
where p.name in ('FINPRD1', 'HCMPRD1', 'FINUAT1', 'HCMUAT1', 'FINUAT3','HCMUAT3', 'FINRPT2', 'HCMRPT2', 'FINRPT1', 'HCMRPT1'))

/
select 'srvctl start service -d '|| db_unique_name
from v\$database
/

select 'srvctl status service -d '|| db_unique_name
from v\$database
/
spool off

EOF
cat $SPOOL_FILE
echo "********************************************************************************"
echo "executing above in 10 seconds. Hit CTRL+C to exit"
echo "********************************************************************************"
sleep 10
set -x

sh $SPOOL_FILE


srvctl status service -d $CONTAINER_NAME





