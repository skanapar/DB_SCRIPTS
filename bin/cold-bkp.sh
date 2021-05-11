#!/bin/bash
#
# efierro - Enkitec
#
############
# Common Vars
############
DIRN=`dirname $0`
SCRN=`basename $0`
NOW=`date +'%Y%m%d-%H%M'`
LOGF="${DIRN}/log/${SCRN}.${NOW}.log"

############
# Custom Vars
############
OHLOC="/oracle/UNIFI_PAGOLD"
DBOH="/us1001/app/oraprod/product/11.2.0.3/db_1"
BKLOC="/oracle/shared/backups/PATCHES_BKP/20140117"
OUSER="/ as sysdba"
ENV="PAGOLD"
MAILLIST="edwin.ching@brinkslatam.com,efierro@enkitec.com,jnano@enkitec.com"

ADMIN_SCRIPTS_HOME1="/oracle/UNIFI_PAGOLD/inst/apps/PAGOLD_latptyuniap01/admin/scripts"
APPUSER1="applgold@latptyuniap01"

ADMIN_SCRIPTS_HOME2="/oracle/UNIFI_PAGOLD/inst/apps/PAGOLD_latptyuniap02/admin/scripts"
APPUSER2="applgold@latptyuniap02"

APPSPWD="u5ZWd6Fo"

############
# Main
############

# Source functions
. ${DIRN}/func.sh
# set environment:
. ~/${ENV}.env

#chkdb_status

log "Stopping App Services"
sshcom "${ADMIN_SCRIPTS_HOME1}/adstpall.sh apps/$APPSPWD" $APPUSER1
sshcom "${ADMIN_SCRIPTS_HOME2}/adstpall.sh apps/$APPSPWD" $APPUSER2

srvctl stop listener
log "Wait 5 min for app services to die"
sleep 300
srvctl stop database -d $ENV -o IMMEDIATE

log "backup apps home in $APPUSER1 and $APPUSER2"
sshcom "tar czpf ${BKLOC}/${ENV}_APPS1_${NOW}.tgz $OHLOC" $APPUSER1
sshcom "tar czpf ${BKLOC}/${ENV}_APPS2_${NOW}.tgz $OHLOC" $APPUSER2

log "backup database"
rman target / <<EOF
startup mount;
run{
allocate channel c1 device type disk;
allocate channel c2 device type disk;
allocate channel c3 device type disk;
allocate channel c4 device type disk;
allocate channel c5 device type disk;
allocate channel c6 device type disk;
allocate channel c7 device type disk;
allocate channel c8 device type disk;
sql 'alter system archive log current';
BACKUP AS COMPRESSED BACKUPSET TAG 'COLD_B4_EBS_PATCHES' DATABASE 
	keep forever restore point 'BEFORE_JAN_PATCHES' include current controlfile;
backup archivelog all;
release channel c1;
release channel c2;
release channel c3;
release channel c4;
release channel c5;
release channel c6;
release channel c7;
release channel c8;
}
exit
EOF

#log "backup DB home"
#tgz ${BKLOC}/${ENV}_RDBMS_HOME_${NOW}.tgz $OHLOC

srvctl start database -d $ENV
srvctl start listener

#log "Starting App Services"
#sshcom "${ADMIN_SCRIPTS_HOME1}/adstrtal.sh apps/$APPSPWD" $APPUSER1
#sshcom "${ADMIN_SCRIPTS_HOME2}/adstrtal.sh apps/$APPSPWD" $APPUSER2

# send log by email:
nfy $MAILLIST

exit 0

