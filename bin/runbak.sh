#!/bin/bash
# Usage: runbak <backup_type> <CDB> [P]
# Where: backup_type is one of inc0, inc1, arch or sync
#   and: CDB is RAC database name
#  P is optional for prod backups (retention 120 days)

export BAK_CMD=$1
export DB_ENV=$2
export RETN=$3
export DBA_RMAN_DIR=/db_share/RMAN_Backups
export DBA_RMAN_SCR=$DBA_RMAN_DIR/scr
export DBA_RMAN_LOG=$DBA_RMAN_DIR/log
export CATCONN="rco/26wXYMbrYeBZtMO2b@catalog"
export BAK_TYP=""
export MAILTO="cf.database.client.idc@accenture.com"
export TSTAMP=`date +%Y%m%d.%H%M`

if [ $# -lt 2 ]
then
echo " Usage: runbak.sh <backup_type> <CDB> [P]"
exit 1
fi

# Set Exadata RAC instance environment:
# <DBNAME>.env scripts must exist in /home/oracle
. /home/oracle/${DB_ENV}.env

if test "$RETN" = "P"
then
    if test "$BAK_CMD" = "inc0"
    then
	export BAK_TYP="Level 0 120d"
        echo $BAK_TYP
        export LOGF=$DBA_RMAN_LOG/bkp_inc0_${ORACLE_SID}.${TSTAMP}.log
	$DBA_RMAN_SCR/rman_inc0_120 $ORACLE_SID
    elif test "$BAK_CMD" = "inc1"
    then
        export BAK_TYP="Level 1 120d"
        echo $BAK_TYP
        export LOGF=$DBA_RMAN_LOG/bkp_inc1_${ORACLE_SID}.${TSTAMP}.log
        $DBA_RMAN_SCR/rman_inc1_120 $ORACLE_SID
fi
else
    if test "$BAK_CMD" = "inc0"
    then
	export BAK_TYP="Level 0 14d"
        echo $BAK_TYP
        export LOGF=$DBA_RMAN_LOG/bkp_inc0_${ORACLE_SID}.${TSTAMP}.log
	$DBA_RMAN_SCR/rman_inc0 $ORACLE_SID
    elif test "$BAK_CMD" = "inc1"
    then
        export BAK_TYP="Level 1 14d"
        echo $BAK_TYP
        export LOGF=$DBA_RMAN_LOG/bkp_inc1_${ORACLE_SID}.${TSTAMP}.log
        $DBA_RMAN_SCR/rman_inc1 $ORACLE_SID
    elif test "$BAK_CMD" = "arch"
    then
	export BAK_TYP="Archive"
        echo $BAK_TYP
        export LOGF=$DBA_RMAN_LOG/bkp_arch_${ORACLE_SID}.${TSTAMP}.log
	$DBA_RMAN_SCR/rman_arch $ORACLE_SID
    elif test "$BAK_CMD" = "sync"
    then
        export BAK_TYP="Catalog Synchronization"
        echo $BAK_TYP
        export LOGF=$DBA_RMAN_LOG/bkp_sync_${ORACLE_SID}.${TSTAMP}.log
	$DBA_RMAN_SCR/rman_sync $ORACLE_SID
    fi
fi

DBERR=""

/bin/find $DBA_RMAN_LOG -mtime +7 -exec rm {} \;

DBERR=`egrep -n "ORA-|RMAN-" $LOGF | grep -v "RMAN-08137" | grep -v "ORA-15028"| grep -v "RMAN-08139" | grep -v "RMAN-06207"| grep -v "RMAN-06208"| grep -v "RMAN-06210"| grep -v "RMAN-06211"| grep -v "RMAN-06212"| grep -v "RMAN-06213"| grep -v "RMAN-06214"`

if [ -z "$DBERR" ]
then
   echo "No Errors in $LOGF"
else
   DBERR="Backup Errors Found !! \n Hostname: `hostname` \n\n Check the following file for errors: \n $LOGF \n $DBERR"
   echo -e $DBERR |mailx -s " $BAK_TYP $DB_ENV Backup Completed With Errors" $MAILTO
fi
