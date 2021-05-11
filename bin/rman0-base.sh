#!/bin/bash
# efierro - Enkitec
#
#
export ORACLE_HOME=/oracle/product/11.2.0.3/db
export PATH=$PATH:$ORACLE_HOME/bin
export BDIR=/home/oracle/enkitec
#SIDLIST=`awk -F: '/^[^#]/ && $1 != "ims" && $1 != "sde" {print $1}' /etc/oratab`
export SIDLIST=oem
export ML="efierro@enkitec.com"
#
for ORACLE_SID in $SIDLIST
do
export ORACLE_SID
export TSTAMP=`date +%Y%m%d.%H%M`
export LOGF=$BDIR/backup_l0_${ORACLE_SID}.${TSTAMP}.log
time rman log $LOGF <<EOF
connect target /
run {
allocate channel d1 type disk;
allocate channel d2 type disk;
allocate channel d3 type disk;
allocate channel d4 type disk;
allocate channel d5 type disk;
allocate channel d6 type disk;
allocate channel d7 type disk;
allocate channel d8 type disk;
backup incremental level 0 cumulative as COMPRESSED BACKUPSET
        tag 'FULL LVL 0' database include current controlfile;
backup as COMPRESSED BACKUPSET
        tag 'ARC LOGS' archivelog all
		not backed up 
		delete all input;
release channel d1;
release channel d2;
release channel d3;
release channel d4;
release channel d5;
release channel d6;
release channel d7;
release channel d8;
}
#allocate channel for maintenance type disk;
#delete noprompt obsolete device type disk;
#release channel;
quit;
EOF
done

if [ "$?" -ne "0" ]; then
     mailx -s "BRINKS PAGOLD RMAN Backup failed"  $ML < $LOGF

else
     mailx -s "BRINKS PAGOLD RMAN Backup Success" $ML < $LOGF
fi

exit

