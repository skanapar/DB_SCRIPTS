# usage: conv_to_snap.sh <DB_NAME>
set -x
#export ORACLE_SID=
#export ORACLE_SID=${1}1
#export ORACLE_HOME=/u02/app/oracle/product/12.2.0/dbhome_14
#echo $ORACLE_SID $ORACLE_HOME
#export TNS_ADMIN=/u02/app/oracle/product/12.2.0/dbhome_14/network/admin/STSFMTCS
export ORACLE_UNQNAME=$1
source /home/oracle/${1}.env

env | grep ORA
env | grep TNS

echo "Stopping database $1"
srvctl stop database -d $1 -o immediate

srvctl status database -d $1

#echo
#echo Press ENTER to Convert to SNAPSHOT STANDBY on one node
#read

$ORACLE_HOME/bin/sqlplus -s / as sysdba << EOF
set echo on 
prompt Mounting Instance
startup mount;

select name, db_unique_name, open_mode, database_role from v\$database;

prompt Ending Managed Recovery if enabled
alter database recover managed standby database cancel;
prompt Converting to SNAPSHOT STANDBY
alter database convert to snapshot standby;
prompt Shutting down
shutdown immediate;
prompt Re-mounting
startup mount;
alter database open;

select name, db_unique_name, open_mode, database_role from v\$database;

prompt Restarting database.... 
shutdown immediate

quit
EOF

srvctl start database -d $1 -o OPEN
srvctl status database -d $1 -v



