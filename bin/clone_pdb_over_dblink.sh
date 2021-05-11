#!/bin/bash
#
# Name:   clone_pdb_over_dblink.sh
# Author: Sri kanaparthy
# Version 1.0
# Modified: 07-FEB-2019

# USAGE:  
# Dependencies:  Script framework,DB LINK matching the sourcedb name in the source container
# Modification Log:
 

usage() { echo "Usage: $0 -s source_pdb_name  -t target_pdb_name  -l db_link_name -C container_name" 1>&2; exit 1; }

while getopts ":s:t:l:C:" o; do
    case "${o}" in
        s)
            SOURCE_PDB_NAME=${OPTARG}
            ;;
        l)
            DB_LINK_NAME=${OPTARG}
            ;;
        t)
            TARGET_PDB_NAME=${OPTARG}
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

if [[ -z ${SOURCE_PDB_NAME} || -z ${TARGET_PDB_NAME}|| -z ${CONTAINER_NAME}|| -z  ${DB_LINK_NAME}  ]]
then
usage
fi
BASE_DIR=$(dirname "$0"); export BASE_DIR
SCRIPT_NAME=$(basename "$0"); export SCRIP_NAME

 
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

set +x
get_wallet_pass DUMMY
exit_if_error $?



LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}_${LOG_SUFFIX}.log
sleep 1
exec > >(tee -i ${LOG_FILE})
exec 2>&1

 
.  ~oracle/${CONTAINER_NAME}.env >/dev/null;

exit_if_error $?
echo "************************************************************"
echo -n "beginning clone "
date

sqlplus  -s "/as sysdba" <<EOF
whenever sqlerror exit 99
whenever oserror exit 98
select name from v\$database;
set echo off
set termout off

set serveroutput on
declare
v_dummy varchar2(100);
begin

select name
into v_dummy
from v\$database;

--if v_dummy <> 'XXXXX' then
----RAISE_APPLICATION_ERROR (-20009, 'Script can only be run on  database');

--end if;

begin
execute immediate 'alter pluggable database  ${TARGET_PDB_NAME}  close immediate instances=all';
execute immediate 'drop pluggable database ${TARGET_PDB_NAME}  including datafiles';
exception
when others then null;
dbms_output.put_line('error dropping  ${TARGET_PDB_NAME}'|| sqlerrm);
dbms_output.put_line('Ignoring error and continuing..');
end;

execute immediate 'create pluggable database ${TARGET_PDB_NAME} from $SOURCE_PDB_NAME@$DB_LINK_NAME parallel 8 keystore identified by "$WALLET_PASS"';

end;
/

set echo on
set feedback on
set termout on

alter pluggable database ${TARGET_PDB_NAME} open instances=all
/
show pdbs

set serveroutput on
declare
pdb_open_count number;
begin
select  count(*)
into pdb_open_count
from gv\$pdbs p
where name=UPPER('${TARGET_PDB_NAME}')
and open_mode like 'READ%'
;


if pdb_open_count <> 2
then
dbms_output.put_line('Only '||pdb_open_count ||' open for  ${TARGET_PDB_NAME}');
raise_application_error(-20001, ' PDBS not open');
end if;
end;
/


EOF
RET_VAL=$?
echo -n "End  clone "
date
echo "************************************************************"

exit $RET_VAL
