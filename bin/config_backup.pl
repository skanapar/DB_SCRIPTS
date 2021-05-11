#!/usr/bin/perl

##################################################################################################
#  Name:        config_backup                                                                    #
#  Author:      Randy Johnson                                                                    #
#  Description: Configures backup user account used by CommVault                                 #
#                                                                                                #
#  Input Parms: -s(id)         ORACLE_SID. Not required if ORACLE_SID environment variable is    #
#                              exported.                                                         #
#               -ch(eck        Check the current configuration.                                  #
#               -co(nfigure)   create the cvbk database account. Executes the following...       #
#                              SQL> create user cvbk identified by "backMeUp1";                  #
#                              SQL> grant create session                to cvbk;                 #
#                              SQL> grant sysdba, alter system          to cvbk;                 #
#                              SQL> grant select on SYS.V_$DATABASE     to cvbk;                 #
#                              SQL> grant select on SYS.V_$DATAFILE     to cvbk;                 #
#                              SQL> grant select on SYS.DBA_TABLESPACES to cvbk;                 #
#                              SQL> grant select on SYS.V_$ARCHIVE_DEST to cvbk;                 #
#               -u(nconfigure) Drop's the cvbk database user account "drop user cvbk cascade".   #
#               -h(elp)        Displays the Usage message.                                       #
#               -v(ersion)     Displays version information.                                     #
#                                                                                                #
#  Return Code: >0 indicates failure.                                                            #
#                                                                                                #
##################################################################################################
# MODIFICATION HISTORY:                                                                          #
#                                                                                                #
# Date       Ver  Who              Change Description                                            #
# ---------- ---- ---------------- --------------------------------------------------            #
# 01/21/2012 1.00 Randy Johnson    Created.                                                      #
##################################################################################################


# Import Modules/Functions
#--------------------------#
use File::Basename;
use File::Path;
use Getopt::Long;
use Sys::Hostname;
use FindBin;
use lib "$FindBin::Bin";

# -------------------------------------------#
#  Main Program                              #
# -------------------------------------------#
$Basename          = basename($0);
$Version           = '1.0';
$HostName          = hostname();
$MainRC            = 0;
$ArgCount          = @ARGV;
($CmdName,$cmdExt) = split('\.', $Basename);

# Queries used for checking privileges
$UserCheckSQL         = "select count(*) from dba_users where username='CVBK'";
$SelectDatabaseSQL    = "select count(*) from dba_tab_privs where grantee='CVBK' and owner='SYS' and privilege='SELECT' and table_name='V_\$DATABASE'";
$SelectDatafileSQL    = "select count(*) from dba_tab_privs where grantee='CVBK' and owner='SYS' and privilege='SELECT' and table_name='V_\$DATAFILE'";
$SelectTablespacesSQL = "select count(*) from dba_tab_privs where grantee='CVBK' and owner='SYS' and privilege='SELECT' and table_name='DBA_TABLESPACES'";
$SelectArchiveDestSQL = "select count(*) from dba_tab_privs where grantee='CVBK' and owner='SYS' and privilege='SELECT' and table_name='V_\$ARCHIVE_DEST'";
$SelectAnyTableSQL    = "select count(*) from dba_sys_privs where grantee='CVBK' and privilege='SELECT ANY TABLE'";
$AlterSystemSQL       = "select count(*) from dba_sys_privs where grantee='CVBK' and privilege='ALTER SYSTEM'";
$SysDBASQL            = "select COUNT(*) from v\$pwfile_users where username='CVBK' and SYSDBA='TRUE'";

# Command line options
# --------------------------------
$OptOutput = GetOptions (
	'sid:s'          => \$OracleSid,
	'check'          => \$Checkconfig,
	'configure'      => \$Configure,
  'unconfigure'    => \$Unconfigure,
  'help'           => \$Help,
  'trace'          => \$Trace,
  'version'        => \$ShowVersion
);

if ($OptOutput != 1) {
  PrintUsage();
  exit 1;
}

if ($Help) {
  PrintUsage();
  exit 0;
}

if ($ShowVersion) {
  printf $CmdName . " : Release $Version - Test\n";
  exit 0;
}

if ($OracleSid eq '') {
   if ($ENV{ORACLE_SID} eq '') {
      printf "You must specify an ORACLE_SID with the -(s)id option or export \$ORACLE_SID before running this command.\n\n";
      PrintUsage();
      exit 1;
   } else {
      $OracleSid = $ENV{ORACLE_SID};
   }
}

$Junk = $Checkconfig + $Configure + $Unconfigure + $Help + $Trace + $ShowVersion;
if ($Junk gt 1) {
  PrintUsage();
	exit 1;
} else {
	if ($Junk eq 0) {
		$Checkconfig = 1;
  }
}

# Validate $ORACLE_SID and setup Oracle environment
$MainRC = SetOracleEnv($OracleSid);
print "TRACE: SetOracleEnv($OracleSid) returned: $MainRC\n" if ($Trace);

if (($Checkconfig) or ($Configure) or ($Unconfigure)) {
  # Check the run state of the database.
  # ------------------------------------
  $DbState = GetDbState();
  $DbName  = GetDbName();
  
  printf "\nConnected to  : %s\n", $DbName;  
  printf "Database is   : %s\n\n", $DbState;  
  
  if ($DbState ne 'OPEN') {
  	print "The database must be open.\n";
  	exit 1;
  }
  
  $UserCheck         = CheckPrivileges($UserCheckSQL);
  $SelectDatabase    = CheckPrivileges($SelectDatabaseSQL);
  $SelectDatafile    = CheckPrivileges($SelectDatafileSQL);
  $SelectTablespaces = CheckPrivileges($SelectTablespacesSQL);
  $SelectArchiveDest = CheckPrivileges($SelectArchiveDestSQL);
  $SelectAnyTable    = CheckPrivileges($SelectAnyTableSQL);
  $AlterSystem       = CheckPrivileges($AlterSystemSQL);
  $SysDBA            = CheckPrivileges($SysDBASQL);
}    

if ($Configure) {
	if (not $UserCheck) {
    print "Creating CVBK user account:\n";
    ExecSQL('create user CVBK identified by "backMeUp1" default tablespace USERS temporary tablespace TEMP');
    print "   Granting CREATE SESSION.\n";
    ExecSQL('grant CREATE SESSION to CVBK');
    $UserCheck = CheckPrivileges($UserCheckSQL);
    if (not $UserCheck) {
      print "\n\nFailed to create the CVBK user account. Exiting...\n";
      exit 1;
    }
  } else {
  	print "CVBK user account already exists.\n\n";
  }

  if (not $SelectDatabase) {
    print "   Granting SELECT on V\$DATABASE.\n";
     ExecSQL('grant SELECT on SYS.V_$DATABASE to CVBK');
     $SelectDatabase = CheckPrivileges($SelectDatabaseSQL);
     if (not $SelectDatabase) {
       print "\n\nGrant SELECT failed. Exiting...\n";
       exit 1;
     }     	
  }
  
  if (not $SelectDatafile) {
  	print "   Granting SELECT on V\$DATAFILE.\n";
    ExecSQL('grant SELECT on SYS.V_$DATAFILE to CVBK');
    $SelectDatafile = CheckPrivileges($SelectDatafileSQL);
    if (not $SelectDatabase) {
      print "\n\nGrant SELECT failed. Exiting...\n";
      exit 1;
    }     	
  }
  
  if (not $SelectTablespaces) {
  	print "   Granting SELECT on DBA_TABLESPACES.\n";
    ExecSQL('grant SELECT on DBA_TABLESPACES to CVBK');
    $SelectTablespaces = CheckPrivileges($SelectTablespacesSQL);
    if (not $SelectTablespaces) {
      print "\n\nGrant SELECT failed. Exiting...\n";
      exit 1;
    }     	
  }

  if (not $SelectArchiveDest) {
    print "   Granting SELECT on V\$ARCHIVE_DEST.\n";
    ExecSQL('grant SELECT on SYS.V_$ARCHIVE_DEST to CVBK');
    $SelectArchiveDest = CheckPrivileges($SelectArchiveDestSQL);
    if (not $SelectArchiveDest) {
      print "\n\nGrant SELECT failed. Exiting...\n";
      exit 1;
    }     	
  }

  if (not $SelectAnyTable) {
    print "   Granting SELECT ANY TABLE.\n";
    ExecSQL('grant SELECT ANY TABLE to CVBK');
    $SelectAnyTable = CheckPrivileges($SelectAnyTableSQL);
    if (not $SelectAnyTable) {
      print "\n\nGrant SELECT ANY TABLE failed. Exiting...\n";
      exit 1;
    }     	
  }

  if (not $AlterSystem) {
    print "   Granting ALTER SYSTEM.\n";
    ExecSQL('grant ALTER SYSTEM to CVBK');
    $AlterSystem = CheckPrivileges($AlterSystemSQL);
    if (not $AlterSystem) {
      print "\n\nGrant ALTER SYSTEM failed. Exiting...\n";
      exit 1;
    }     	
  }

  if (not $SysDBA) {
    print "   Granting SYSDBA.\n\n";
    ExecSQL('grant SYSDBA to CVBK');
    $SysDBA = CheckPrivileges($SysDBASQL);
    if (not $SysDBA) {
      print "\n\nGrant SYSDBA failed. Exiting...\n";
      exit 1;
    }     	
  }
}

if (($Checkconfig) or ($Configure)) {
	print "Checking required user privileges:\n";
  if ($SelectDatabase) {
  	print "   V\$DATABASE check..................passed\n"; 
  } else {
  	print "   V\$DATABASE check..................failed\n"; 
  }

  if ($SelectDatafile) {
  	print "   V\$DATAFILE check..................passed\n"; 
  } else {
  	print "   V\$DATAFILE check..................failed\n"; 
  }
  
  if ($SelectTablespaces) {
  	print "   DBA_TABLESPACES check.............passed\n"; 
  } else {
  	print "   DBA_TABLESPACES check.............failed\n"; 
  }

  if ($SelectArchiveDest) {
  	print "   V\$ARCHIVE_DEST check..............passed\n"; 
  } else {
  	print "   V\$ARCHIVE_DEST check..............failed\n"; 
  }

  if ($SelectAnyTable) {
  	print "   SELECT ANY TABLE check............passed\n"; 
  } else {
  	print "   SELECT ANY TABLE check............failed\n"; 
  }

  if ($AlterSystem) {
  	print "   ALTER SYSTEM check................passed\n"; 
  } else {
  	print "   ALTER SYSTEM check................failed\n"; 
  }

  $SysDBA = CheckPrivileges($SysDBASQL);
  if ($SysDBA) {
  	print "   SYSDBA check......................passed\n"; 
  } else {
  	print "   SYSDBA check......................failed\n"; 
  }
}

$UserCheck = CheckPrivileges($UserCheckSQL);
if ($Unconfigure) {
  if ($UserCheck) {
  	print "Dropping the CVBK user account.\n";
    ExecSQL('drop user CVBK cascade');
  } else {
  	print "The CVBK user account does not exist.\n";
  }
}

# ------------------------------------------------------------
#  Subroutine Definitions
# ------------------------------------------------------------

# Sub : SetOracleEnv($)
# Desc: Make sure database has a valid oratab entry
# Args: $0 is the ORACLE_SID to validate
# Retn: 0 for success, >1 failure
#------------------------------------------------------------------------
sub SetOracleEnv($) {
   my $OraSid = shift;

   if ($Trace) {
      print "TRACE: Entering sub SetOracleEnv(\$)\n";
      print "TRACE: Parameters:\n";
      print "TRACE:    \$OraSid = $OraSid\n";
   }

   my $tmpSid;
   my $tmpHome;
   my $ORATAB;

   if ( -r '/etc/oratab') {
      $ORATAB = '/etc/oratab';
   } elsif ( -r '/var/opt/oracle/oratab') {
      $ORATAB = '/var/opt/oracle/oratab';
   }

   if (defined($ORATAB)) {
      if (! open (ORATAB, "<$ORATAB")) {
         PrintError("Unable to open oratab file: $ORATAB\n");
         return 1;
      }

      my @Oratab = ();
      my $FoundFirstEntry = 0;
      while (<ORATAB>) {
         next if /^\s*$/;  # skip blank lines
         next if /^\s*\#/; # skip comment lines
         next if /^\s*\*/; # skip comment lines
         chomp();
         print "TRACE: $_\n" if ($Trace);
         if (! m/^($OraSid):([\S]+):[Y,N,y,n].*$/) {
            next;
         } else {
            $tmpSid  = $1;
            $tmpHome = $2;
         }
      }
      close(ORATAB);

      if ($tmpHome eq '') {
         PrintError("Invalid or missing entry for \[$OraSid\] in $ORATAB file.");
         return 1;
      } else {
         $ENV{ORACLE_SID}  = $tmpSid;
         $ENV{ORACLE_HOME} = $tmpHome;
         $ENV{TNS_ADMIN}   = $tmpHome . "/network/admin";
         use Env 'ORACLE_SID';
         use Env 'ORACLE_HOME';
      }
   } else {
      my $error_string  = 'Unable to find readable oratab file\n';
      return 1;
   }

   if ( ! defined $ENV{ORACLE_HOME}) {
      PrintError("\$ORACLE_HOME is undefined");
      return 1;
   }
   
   # If sqlplus exists and is executable
   if (-x "$ENV{ORACLE_HOME}/bin/sqlplus") {
     $Sqlplus = "$ENV{ORACLE_HOME}/bin/sqlplus -s /nolog";
   } else {
     PrintError("Cannot find sqlplus in $ENV{ORACLE_HOME}/bin");
     return 1;
   }
   return 0;
}

# Sub GetDbState()
# Desc: Get the current state of the database (down, mounted, open)
# Args: $0 is the database connect string
# Retn: MOUNTED/OPEN/STARTED
#-------------------------------------------------------------------------
sub GetDbState($) {
   my $ConnectString = '/ as sysdba';

   my $DbState       = 'DOWN';
   my $SqlFileName   = "$ENV{DIXIE_HOME}/tmp/${main::prog}sql.$$";
   my $rc = 0;
   my @ErrorStack = ();

   open (SQL_FILE,">$SqlFileName") or do {
      PrintError("Unable to open file $$SqlFileName");
      exit 1;
   };

   print SQL_FILE "connect $ConnectString\n";
   print SQL_FILE "set pagesize 0\n";
   print SQL_FILE "set feedback on\n";
   print SQL_FILE "select upper(status) from v\$instance;\n";
   print SQL_FILE "exit\n";
   close(SQL_FILE);

   my $SqlOut = `$Sqlplus \@$SqlFileName`;

   if ($SqlOut =~ m/ORA-01034.*/) {
      $DbState = 'DOWN';
   } elsif ($SqlOut =~ m/^(MOUNTED|OPEN|STARTED)[\s]*$/im) {
      chomp($DbState = $1);
   } else {
      ($rc, @ErrorStack) = ErrorCheck($SqlOut);
      if ($rc) {
         my $ErrorMsg;
         foreach my $line (@ErrorStack) {
            $ErrorMsg .= "$line\n";
         }
         PrintError($ErrorMsg);
         if ($Trace) {
            print "TRACE: Exiting sub GetDbState(\$)\n";
            print "TRACE: Exiting: \$rc = $rc\n";
         }
         exit $rc;
      } else {
         PrintError("Cannot determine the state of the database\n");
         if ($Trace) {
            print "TRACE: Exiting sub GetDbState(\$)\n";
            print "TRACE: Exiting: \$rc = $rc\n";
         }
         exit 1;
      }
   }
   unlink "$SqlFileName";
   if ($Trace) {
      print "TRACE: Exiting sub GetDbState(\$)\n";
      print "TRACE: Returning: \$DbState = $DbState\n";
   }
   return $DbState;
}

# Sub CheckPrivileges()
# Desc: Check for required database privileges
# Args: 0 is the SQL Query
# Retn: COUNT(*)
#-------------------------------------------------------------------------
sub CheckPrivileges($) {
	 my $SqlText = shift;

   (my $rc, my $SqlOut) = RunSqlplus($SqlText);
   TrimStr($SqlOut); 
   ###! return ($rc, $SqlOut);
   return $SqlOut;   
}

# Sub ExecSQL($)
# Desc: Check for required database privileges
# Args: 0 is the SQL Statement to execute.
# Retn: COUNT(*)
#-------------------------------------------------------------------------
sub ExecSQL($) {
	 my $SqlText = shift;
   ###! my $SqlFileName   = "$ENV{DIXIE_HOME}/tmp/${main::prog}sql.$$";
   ###! my $rc = 0;
   ###! my @ErrorStack = ();

   (my $rc, my $SqlOut) = RunSqlplus($SqlText);
   TrimStr($SqlOut); 
   ###! return ($rc, $SqlOut);
   return $SqlOut;   

   ###! open (SQL_FILE,">$SqlFileName") or do {
   ###!    PrintError("Unable to open file $$SqlFileName");
   ###!    exit 1;
   ###! };
   ###! 
   ###! print "$SQL\n" if ($Trace);
   ###! 
   ###! # Does the CVBK user exist?
   ###! print SQL_FILE "connect / as sysdba\n";
   ###! print SQL_FILE "set pagesize 0\n";
   ###! print SQL_FILE "set feedback off\n";
   ###! print SQL_FILE $SQL . ";\n";
   ###! print SQL_FILE "exit\n";
   ###! close(SQL_FILE);
   ###! my $SqlOut = `$Sqlplus \@$SqlFileName`;
   ###! 
   ###! ($rc, @ErrorStack) = ErrorCheck($SqlOut);
   ###! if ($rc) {
   ###!    my $ErrorMsg;
   ###!    foreach my $line (@ErrorStack) {
   ###!       $ErrorMsg .= "$line\n";
   ###!    }
   ###!    PrintError($ErrorMsg);
   ###!    exit $rc;
   ###! } else {
   ###!   TrimStr($SqlOut);
   ###!   return $SqlOut;
   ###! }
}


# Sub ErrorCheck($)
# Desc: Check a log file for SQL PLus & Rman errors
# Args: $0 is the file to scan for errors
# Retn: 1=Failure
#       2=Warning
#       3=Informational
#-------------------------------------------------------------------------
sub ErrorCheck($) {
   my $Output = shift;

   if ($Trace) {
      print "TRACE: Entering sub ErrorCheck(\$)\n";
      print "TRACE: Parameters:\n";
      print "TRACE:    \$Output = $Output\n";
   }

   my @ErrorStack = ();
   my $rc         = 0;
   my $FoundError = 0;
   my $RmanError  = 0;
   my $Severity   = 0;
   my $SQLError   = 0;
   my $RmanError  = 0;

   if ($Output) {
      if (-T $Output) {
         open(OUTPUT, "<$Output");
         @AllLines = <OUTPUT>;
         chomp(@AllLines);
      } else {
         @AllLines = split("\n", $Output);
      }

      print "TRACE: Checking \$Output for errors.\n" if ($Trace);

      foreach $Line (@AllLines) {
         next if $Line =~ /^\s*$/;  # skip blank lines

         # Check for warning and error messages
         $RmanError = 1 if ($Line =~ m/^RMAN-00569:.*$/); # This is the beginning of an RMAN stack trace.

         # RMAN Errors
         if ($Line =~ m/^RMAN-[\d]+:.*$/) {
           push @ErrorStack, $Line;
         }

         # Database, Sqlplus & Other Errors
         if ((($Line =~ m/^ORA-[\d]+:.*$/)  or
              ($Line =~ m/^SP2-[\d]+:.*$/)  or
              ($Line =~ m/.*error.*$/)      or
              ($Line =~ m/.*WARNING.*/))    and
              (not $Line =~ m/.*WARNING: Oracle Test Disk API.*/)) {
           push @ErrorStack, $Line;
           $SQLError = 1;
         }
      }
      close(OUTPUT) if (-T $Output);
   }

   if ($SQLError) {
      $Severity = 1;
   }

   if ($RmanError) {
      $Severity = 2;
   }

   if ($Trace) {
      print "TRACE: Exiting sub ErrorCheck(\$)\n";
      print "TRACE: Returning:\n";
      print "TRACE:    \$Severity   = $Severity\n";
      print "TRACE:    \@ErrorStack = @ErrorStack\n";
   }
   return ($Severity, @ErrorStack);
}

# Function: TrimStr()
# Trims leading and trailing blanks off a string.
# ------------------------------------------------
sub TrimStr {
   for (@_) {
       s/^\s*//; # trim leading spaces
       s/\s*$//; # trim trailing spaces
   }
   return @_;
}

# Sub GetDbName()
# Desc: Get the database name from v$database
# Args: $0 is the database connect string
# Retn: Database Name
# ------------------------------------------------
sub GetDbName() {
   my $ConnectString = '/ as sysdba';

   if ($Trace) {
      print "TRACE: Entering sub GetDbName()\n";
      print "TRACE: Parameters:\n";
      print "TRACE:    \$ConnectString = $ConnectString\n";
   }

   my $DbName;

   (my $rc, my $SqlOut) = RunSqlplus("SELECT 'DBNAME:' || NAME FROM V\$DATABASE");

   foreach my $Line (split('\n',$SqlOut)) {
      if ($Line =~ m/^DBNAME:/) {
         ($junk, $DbName) = split(':', $Line);
         last;
      }
   }
   if ($Trace) {
      print "TRACE: Exiting sub GetDbName(\$)\n";
      print "TRACE: Returning: \$rc      = $rc\n";
      print "TRACE:            \$DbName  = $DbName\n";
   }
   return $rc, $DbName;
}

# Sub GetDbUniqueName()
# Desc: Get the database unique name from v$parameter
# Args: $0 is the database connect string
# Retn: Database Unique Name
# ------------------------------------------------
sub GetDbUniqueName($) {
   my $ConnectString = shift;

   if ($Trace) {
      print "TRACE: Entering sub GetDbUniqueName(\$)\n";
      print "TRACE: Parameters:\n";
      print "TRACE:    \$ConnectString = $ConnectString\n";
   }

   my $DbUniqueName;

   (my $rc, my $SqlOut) = RunSqlplus("SELECT 'DBUNIQUE:' || VALUE FROM V\$PARAMETER WHERE NAME = 'db_unique_name'");

   foreach my $Line (split('\n',$SqlOut)) {
      if ($Line =~ m/^DBUNIQUE:/) {
         ($junk, $DbUniqueName) = split(':', $Line);
         last;
      }
   }
   if ($Trace) {
      print "TRACE: Exiting sub GetDbUniqueName(\$)\n";
      print "TRACE: Returning: \$rc           = $rc\n";
      print "TRACE:            \$DbUniqueName = $DbUniqueName\n";
   }
   return $rc, $DbUniqueName;
}

# Sub : RunSqlplus($)
# Desc: Execute a SQL script from Oracle Server Manager/SQLPlus
# Args: $0 is the SQL text
# Retn: 0 if successful, Return code is returned from sqlplus session.
#------------------------------------------------------------------------
sub RunSqlplus($) {
   my $SqlText       = shift;
   my $ConnectString = '/ as sysdba';
   my $SqlFileName   = "$ENV{DIXIE_HOME}/tmp/${main::prog}sql.$$";
   my $rc = 0;

   Unix2Dos($SqlFileName) if ($^O eq 'MSWin32');

   if ($Trace) {
      print "TRACE: Entering sub RunSqlplus(\$\$)\n";
      print "TRACE: Parameters:\n";
      print "TRACE:    \$ConnectString = $ConnectString\n";
      print "TRACE:    \$SqlText       = $SqlText      \n";
      print "TRACE: Other:\n";
      print "TRACE:    $SqlFileName = $SqlFileName\n";
   }

   open (SQL_FILE,">$SqlFileName") or do {
      PrintError("Unable to open file $SqlFileName");
      if ($Trace) {
         print "TRACE: Exiting sub RunSqlplus(\$\$)\n";
         print "TRACE: Returning: 1\n";
      }
      return 1;
   };

   print SQL_FILE "connect $ConnectString\n";
   print SQL_FILE "set pagesize 0\n";
   print SQL_FILE "set feedback off\n";
   print SQL_FILE "set echo off\n";
   print SQL_FILE "set head off\n";
   print SQL_FILE "$SqlText;\n";
   print SQL_FILE "exit\n";

   close(SQL_FILE);

   my $SqlOut = `$Sqlplus \@$SqlFileName`;
   unlink "$SqlFileName";

   my ($rc, @ErrorStack) = ErrorCheck($SqlOut);
   if ($rc) {
      my $ErrorMsg;
      foreach my $line (@ErrorStack) {
         $ErrorMsg .= "$line\n";
      }
      PrintError($ErrorMsg);
      if ($Trace) {
         print "TRACE: Exiting sub RunSqlplus(\$)\n";
         print "TRACE: Returning: \$rc = $rc\n";
      }
      return $rc;
   }
   if ($Trace) {
      print "TRACE: Exiting sub RunSqlplus(\$)\n";
      print "TRACE: Returning: \$rc     = $rc\n";
      print "TRACE:            \$SqlOut = $SqlOut\n";
   }
   return $rc, $SqlOut;
}

# Function: PrintUsage()
# Print Usage
# ------------------------------------------------
sub PrintUsage() {
   print "\nUsage: $basename [-s(id) ORACLE_SID] [-co(nfigure) -ch(eck) -u(nconfigure -h(elp) -v(ersion)]\n";
   print "Where: -s(id)         = ORACLE_SID\n";
   print "       -co(onfigure)  = Configure the user account for CommVault.\n";
   print "       -ch(eck)       = Verify the current configuration.\n";
   print "       -u(nconfigure) = Drops the CVBK user account (cascade).\n";
   print "       -v(ersion)     = Prints version information.\n";
   print "       -h(elp)        = Prints this message.\n\n";
   print "Examples:\n";
   print "       $CmdName\n";
   print "       $CmdName -configure\n";
   print "       $CmdName -s mydb -unconfigure\n";
   print "       $CmdName -s mydb -check\n";
   print "       $CmdName -h\n";
   print "       $CmdName -v\n";
   exit 0;
}

# Sub : PrintError($,$)
# Desc: Print and email a program exception
# Args: $0 is the error message
#       $1 is the hostname the error occurred on (optional)
# Retn: ?
#------------------------------------------------------------------------
sub PrintError($) {
    my $ErrorMsg  = shift;

    print "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n";
    foreach (split /\n/,$ErrorMsg) {
       chomp;
       print "ERROR: $_\n";
    }
    print ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n";
}

exit $MainRC;
# End Program

