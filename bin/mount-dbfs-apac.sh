#!/bin/bash

### This script is from Note 1054431.1, ensure you have the latest version
### Note 1054431.1 provides information about the setup required to use this script

### updated 18-APR-2011

###########################################
### Everyone must set these values
###########################################
### Database name for the DBFS repository as used in "srvctl status database -d $DBNAME"
DBNAME=DBFS

### Mount point where DBFS should be mounted 
MOUNT_POINT=/dbfs2

### Username of the DBFS repository owner in database $DBNAME
DBFS_USER=apac

### RDBMS ORACLE_HOME directory path
ORACLE_HOME=/u01/app/oracle/product/11.2.0.3/dbhome_1

### Full path to a logfile (or /dev/null) for output from dbfs_client's nohup
### Useful for debugging, normally use /dev/null
NOHUP_LOG=/dev/null

### Syslog facility name (default local3)
### This is only needed if you want to capture debug outputs using syslog
LOGGER_FACILITY=local3

###########################################
### If using password-based authentication, set these
###########################################
### This is the plain text password for the DBFS_USER user
DBFS_PASSWD=welcome

### The file used to temporarily store the DBFS_PASSWD so dbfs_client can read it
### This file is removed immediately after it is read by dbfs_client
### The actual filename used will have the PID appended to the name for uniqueness
DBFS_PWDFILE_BASE=/Users/Randy/.dbfs-passwd.txt

### mount options for dbfs_client
MOUNT_OPTIONS=allow_other,direct_io

###########################################
### If using wallet-based authentication, modify these
###########################################
### WALLET should be true if using a wallet, otherwise, false
WALLET=false

### TNS_ADMIN is the directory containing tnsnames.ora and sqlnet.ora used by DBFS
#TNS_ADMIN=/Users/Randy/dbfs/tnsadmin

### mount options for wallet-based mounts are in /etc/fstab

###########################################
### No editing is required below this point
###########################################
MOUNT=/bin/mount
GREP=/bin/grep
AWK=/bin/awk
XARGS='/usr/bin/xargs -r'
ECHO=/bin/echo
LOGGER="/bin/logger -t DBFS_${MOUNT_POINT}"
RMF='/bin/rm -f'
TOUCH=/bin/touch
CHMOD=/bin/chmod
PS=/bin/ps
SLEEP=/bin/sleep
KILL=/bin/kill
READLINK=/usr/bin/readlink
BASENAME=/bin/basename
FUSERMOUNT=/bin/fusermount
STAT=/usr/bin/stat
ID=/usr/bin/id
WC=/usr/bin/wc
SRVCTL=$ORACLE_HOME/bin/srvctl
DBFS_CLIENT=$ORACLE_HOME/bin/dbfs_client
HN=/bin/hostname
PERL=/usr/bin/perl
LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib64
### this is number of seconds to wait for response from status command
### after this, if no respnose, will run clean
PERL_ALARM_TIMEOUT=4
DBFS_PWDFILE=$DBFS_PWDFILE_BASE.$$

export ORACLE_HOME LD_LIBRARY_PATH TNS_ADMIN
export STAT MOUNT_POINT PERL_ALARM_TIMEOUT
export PATH=$ORACLE_HOME/bin:$PATH

logit () {
  ### type: info, error, debug
  type=$1
  msg=$2
  if [ "$type" = "info" ]; then
    $ECHO $msg
    $LOGGER -p ${LOGGER_FACILITY}.info $msg
  elif [ "$type" = "error" ]; then
    $ECHO $msg
    $LOGGER -p ${LOGGER_FACILITY}.error $msg
  elif [ "$type" = "debug" ]; then
    $ECHO $msg
    $LOGGER -p ${LOGGER_FACILITY}.debug $msg
  fi
}

### must not be root
if [ `$ID -u` -eq 0 ]; then
  logit error "Run this as the Oracle software owner, not root"
  exit 1
fi

### determine how we were called, derive location
SCRIPTPATH=`$READLINK -f $0`
SCRIPTNAME=`$BASENAME $SCRIPTPATH`

### must cd to a directory where the oracle owner can get CWD
cd /tmp

case "$1" in
'start')
  logit info "$SCRIPTNAME mounting DBFS at $MOUNT_POINT from database $DBNAME"

  ### check to see if it is already mounted
  $SCRIPTPATH status > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logit error "$MOUNT_POINT already mounted, use \"$SCRIPTNAME stop\" "\
         "before attempting to start"
    $SCRIPTPATH status
    exit 1
  fi

  ### set the ORACLE_SID dynamically based on OCR info, if it is running
  export ORACLE_SID=$($SRVCTL status instance -d $DBNAME -n `$HN -s`| \
                      $GREP 'is running' | $AWK '{print $2}' )
  logit info "ORACLE_SID is $ORACLE_SID"

  ### if there's no SID defined locally or it isn't running, stop
  if [ -z "$ORACLE_SID" -a "$WALLET" = 'false' ]; then
    logit error "No running ORACLE_SID available on this host, exiting"
    exit 2
  fi

  ### if using password-based startup, use this
  if [ "$WALLET" = 'false' -a -n "$DBFS_PASSWD" ]; then
    $RMF $DBFS_PWDFILE
    if [ -f $DBFS_PWDFILE ]; then 
      logit error "please remove $DBFS_PWDFILE and try again"
      exit 1
    fi 

    $TOUCH $DBFS_PWDFILE
    $CHMOD 600 $DBFS_PWDFILE
    $ECHO $DBFS_PASSWD > $DBFS_PWDFILE

    logit info "spawning dbfs_client command using SID $ORACLE_SID"
    (nohup $DBFS_CLIENT ${DBFS_USER}@ -o $MOUNT_OPTIONS \
          $MOUNT_POINT < $DBFS_PWDFILE | $LOGGER -p ${LOGGER_FACILITY}.info 2>&1 & ) &

    $RMF $DBFS_PWDFILE

  elif [ "$WALLET" = true ]; then
    ### in this case, expect that the /etc/fstab entry is configured, 
    ###   just mount (assume ORACLE_SID is already set too)
    logit info "doing mount $MOUNT_POINT using SID $ORACLE_SID with wallet now"

    $MOUNT $MOUNT_POINT
  fi

  ### allow time for the mount table update before checking it
  $SLEEP 1
  ### set return code based on success of mountin
  $SCRIPTPATH status > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logit info "Start -- ONLINE"
    exit 0
  else
    logit info "Start -- OFFLINE"
    exit 1
  fi
  ;;

'stop')
  $SCRIPTPATH status > /dev/null
  if [ $? -eq 0 ]; then
    logit info "unmounting DBFS from $MOUNT_POINT"
    $FUSERMOUNT -u $MOUNT_POINT
    $SCRIPTPATH status > /dev/null
    if [ $? -eq 0 ]; then
      logit error "Stop - stopped, but still mounted, error"
      exit 1
    else
      logit info "Stop - stopped, now not mounted"
      exit 0
    fi
  else
    logit error "filesystem $MOUNT_POINT not currently mounted, no need to stop"
  fi
  ;;

'check'|'status')
  ### check to see if it is mounted
  ### fire off a short process in perl to do the check (need the alarm builtin)
  $PERL <<'TOT'
    $timeout = $ENV{'PERL_ALARM_TIMEOUT'};
    $SIG{ALRM} = sub { 
      ### we have a problem and need to cleanup
      exit 2;
      die "timeout" ;
    };
    alarm $timeout;
    eval {
      $STATUSOUT=`$ENV{'STAT'} -f -c "%T" $ENV{'MOUNT_POINT'} 2>&1 `; 
      chomp($STATUSOUT);
      if ( $STATUSOUT eq 'UNKNOWN (0x65735546)' ) {
        ### status is okay
        exit 0;
      } elsif ( $STATUSOUT =~ /Transport endpoint is not connected/ ) {
        ### we have a problem, need to clean up
        exit 2;
      } else {
        ### filesystem is offline
        exit 1;
      }
    };

TOT

  RC=$?
  ### process return codes from the perl block
  if [ $RC -eq 2 ]; then
    logit error "Found error or timeout while checking status, cleaning mount automatically"
    $SCRIPTPATH clean
    logit debug "Check -- OFFLINE"
    exit 1
  elif [ $RC -eq 1 ]; then
    logit debug "Check -- OFFLINE"
    exit 1
  elif [ $RC -eq 0 ]; then
    logit debug "Check -- ONLINE"
    exit 0
  fi
  ;;

'restart')
  logit info "restarting DBFS" 
  $SCRIPTPATH stop
  $SLEEP 2
  $SCRIPTPATH start
  ;;

'clean'|'abort')
  logit info "cleaning up DBFS nicely using fusermount -u"
  $FUSERMOUNT -u $MOUNT_POINT
  $SLEEP 1
  FORCE_CLEANUP=0
  if [ `$PS -ef | $GREP "$SCRIPTPATH status" | $GREP -v grep | $WC -l` -gt 2 ]; then
    FORCE_CLEANUP=1
  else
    $SCRIPTPATH status > /dev/null 
    if [ $? -eq 0 ]; then FORCE_CLEANUP=1; fi
  fi
  if [ $FORCE_CLEANUP -eq 1 ]; then 
    logit error "tried fusermount -u, still mounted, now cleaning with fusermount -u -z and kill"
    $FUSERMOUNT -u -z $MOUNT_POINT
    $PS -ef | $GREP "$MOUNT_POINT " | $GREP dbfs_client| $GREP -v grep | \
      $AWK '{print $2}' | $XARGS $KILL -9
    $PS -ef | $GREP "$MOUNT_POINT " | $GREP mount.dbfs | $GREP -v grep | \
      $AWK '{print $2}' | $XARGS $KILL -9
    exit 1
  fi
  ;;

*)
  $ECHO "Usage: $SCRIPTNAME { start | stop | check | status | restart | clean | abort }"
  ;;

esac


