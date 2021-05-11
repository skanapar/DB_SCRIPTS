#!/bin/bash
#
export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
export ML="eduardo.fierro@accenture.com,s.kanaparthy@accenture.com,michael.w.fontana@accenture.com,CF.Database.Client.IDC@accenture.com"
export OCI_CONN="lcarter@10.27.160.163"
export OCI_DIR="/acfs02/inbox/"
export ORACLE_SID=$1
export ORAENV_ASK=NO
. /usr/local/bin/oraenv
export ORAENV_ASK=YES
## IMPORTANT, this script will REMOVE all files within the subdirectory below!!:
export BKP_BASE=/oci_backup/daily_bkp
export TSTAMP=`date +%Y%m%d`
export BKP_DIR=${BKP_BASE}/${ORACLE_SID}-$TSTAMP
if [ ! -d $BKP_DIR ]
then
  /bin/mkdir $BKP_DIR
fi
export LOGG=/oci_backup/rman0_${ORACLE_SID}.${TSTAMP}.log
export LOGF=${BKP_DIR}/backup_l0_${ORACLE_SID}.${TSTAMP}.log

log2f()
{
echo -e "`date +%Y%m%d-%H%M`: "$1"\n" >> $LOGG
}


# Make room for new backup
log2f "Start pre-cleanup"

/bin/find $BKP_BASE -mtime +0 -exec rm {} \;

# Take full rman backup
log2f "Start RMAN backup"
/usr/bin/time rman log $LOGF <<EOF
connect target /

run
{
allocate channel x1 type disk format '$BKP_DIR/%d_inc0_s%s_p%p_c%c_t%t_i%I.rman';
allocate channel x2 type disk format '$BKP_DIR/%d_inc0_s%s_p%p_c%c_t%t_i%I.rman';
allocate channel x3 type disk format '$BKP_DIR/%d_inc0_s%s_p%p_c%c_t%t_i%I.rman';
allocate channel x4 type disk format '$BKP_DIR/%d_inc0_s%s_p%p_c%c_t%t_i%I.rman';

   BACKUP AS COMPRESSED BACKUPSET
   INCREMENTAL LEVEL 0 TAG = 'LEVEL_0'
   DATABASE PLUS ARCHIVELOG FILESPERSET 8 tag 'l0disk-$ORACLE_SID';
   backup current controlfile
     format '$BKP_DIR/%d_ctlf_s%s_p%p_c%c_t%t_i%I.rman'
     tag = 'CONTROLFILE';

    release channel x1;
    release channel x2;
    release channel x3;
    release channel x4;
}

quit;
EOF
cat $LOGF >> $LOGG

# Remove remote files older than 3 days
log2f "Remove OCI old files start"
/usr/bin/ssh -c aes128-ctr $OCI_CONN "/bin/find $OCI_DIR -mtime +2 -exec rm {} \;"

# Send to OCI
log2f "Transfer to OCI start"
/usr/bin/rsync -avzh -e "ssh -c aes128-ctr " $BKP_DIR ${OCI_CONN}:${OCI_DIR}

log2f "End Script"
exit
