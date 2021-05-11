# usage: conv_to_phys.h <DB_NAME>
set -x
#export ORACLE_SID=${1}1
#export ORACLE_HOME=/u02/app/oracle/product/12.2.0/dbhome_14
#echo $ORACLE_SID $ORACLE_HOME
#export TNS_ADMIN=/u02/app/oracle/product/12.2.0/dbhome_14/network/admin/STSFMTCS
export ORACLE_UNQNAME=$1
source /home/oracle/${1}.env


$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set echo on 
select name, db_unique_name, open_mode, database_role from v\$database;
quit
EOF

#echo
#echo Stopping DB on all NODES
#read


echo "Stopping database $1"
$ORACLE_HOME/bin/srvctl stop database -d $1 -o immediate

srvctl status database -d $1

#echo
#echo Press ENTER to Convert to PHYSICAL STANDBY on all nodes
#read


$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set echo on
prompt Mounting Instance
startup mount;

select name, db_unique_name, open_mode, database_role from v\$database;

prompt Converting to PHYSICAL STANDBY
alter database convert to physical standby;


prompt Shutting down
shutdown immediate;

quit
EOF

echo "Starting DB on all nodes as PHYSICAL STANDBY"

$ORACLE_HOME/bin/srvctl start database -d $1 -o mount
$ORACLE_HOME/bin/srvctl status database -d $1 -v

$ORACLE_HOME/bin/sqlplus -s / as sysdba <<EOF
set echo on 
select name, db_unique_name, open_mode, database_role from v\$database;
quit
EOF

#echo "Note: Check ALERT LOG and V\$MANAGED_STANDBY for DG status"



