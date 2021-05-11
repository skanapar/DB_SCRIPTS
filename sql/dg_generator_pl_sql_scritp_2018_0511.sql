CREATE OR REPLACE 
PACKAGE        pxddba.pkg_dg_script_gen
/* Formatted on 2/19/2018 6:52:19 PM (QP5 v5.309) */
IS
    /*
        Purpose: Generate scripts data guard

        MODIFICATION HISTORY
        Version     Person      Date        Comments
        --------    ---------   ------      -------------------------------------------
        1.0.0       dcox        2/19/2018   Initial Build - nothing here yet, but would like to replicate Randy Johnson's dggen on PL/SQL - so giving him credit now.

    */

    vgc_directory            CONSTANT VARCHAR2 (200) := 'DG_SCRIPTS_PROD'; -- directory where dg scripts are kept
    vgc_directory_log        CONSTANT VARCHAR2 (200) := 'DG_SCRIPTS_PROD_LOG'; -- directory where dg logs are kept
    vgc_email_to             CONSTANT VARCHAR2 (2000) := 'eduardo.fierro@accenture.com, david.a.cox@accenture.com'; -- email to (can be comma delimited for multiple entries) - use KSH line wrap "\" for long lines
    vgc_run_email_to         CONSTANT VARCHAR2 (2000) := vgc_email_to; -- can have a different address for runtime errors

    vgc_dg_status_ksh_fn   CONSTANT VARCHAR2 (200) := 'dg_status.ksh'; -- filename to write ksh to get dg status
    vgc_dg_status_sql_fn   CONSTANT VARCHAR2 (200) := 'dg_status.sql'; -- filename to write sql to get dg status

    FUNCTION fn_gen_dg_status_ksh (
        p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- add a Y to force an overwrite,
        p_file_name         IN OUT VARCHAR2, -- enter a name if it is different than the default
        p_error_message     IN OUT VARCHAR2                --error message out
                                           )
        RETURN VARCHAR2;

    FUNCTION fn_get_dir_path (p_directory_name IN VARCHAR2   -- Directory Name
                                                          )
        RETURN VARCHAR2;

      FUNCTION fn_gen_dg_status_sql (
          p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- add a Y to force an overwrite,
          p_file_name         IN OUT VARCHAR2, -- enter a name if it is different than the default
          p_error_message     IN OUT VARCHAR2                --error message out
                                             )
          RETURN VARCHAR2;
END pkg_dg_script_gen;                       -- Package spec pkg_dg_script_gen
/


CREATE OR REPLACE 
PACKAGE BODY        pxddba.pkg_dg_script_gen
/* Formatted on 2/19/2018 9:39:43 PM (QP5 v5.309) */
IS
    /*
        Purpose: Generate scripts data guard

        MODIFICATION HISTORY
        Version     Person      Date        Comments
        --------    ---------   ------      -------------------------------------------
        1.0.0       dcox        2/19/2018   Initial Build - nothing here yet, but would like to replicate Randy Johnson's dggen on PL/SQL - so giving him credit now.

        Instructions:
                1) Install this package and get it to compile
                    Use the following notes:
                        NOTES- example scripts for directory creation (Change -- to REM or remove comments if you run from Sql*Plus)
                        -- All scripts for rman here
                        create or replace directory DG_SCRIPTS_PROD as '/u01/dbascripts/production/bin/dg';
                        -- All logs for rman here
                        create or replace directory DG_SCRIPTS_PROD_LOGS as '/u01/dbascripts/production/bin/dg';
                        -- permissions
                        grant read on directory DG_SCRIPTS_PROD to PXDDBA;
                        grant write on directory DG_SCRIPTS_PROD to PXDDBA;
                        -- permissions
                        grant read on directory DG_SCRIPTS_PROD_LOGS to PXDDBA;
                        grant write on directory DG_SCRIPTS_PROD_LOGS to PXDDBA;

                        -- grant to pkg owner
                        grant select on gv_$instance to PXDDBA;
                        -- grant to pkg owner
                        grant select on v_$database to PXDDBA;
                        -- grant to pkg owner
                        grant select on v_$instance to PXDDBA;
                        -- grant to pkg owner
                        grant select on dba_directories to PXDDBA;

                2) Make sure the owner to this package has connect, resource and DBA (note DBA may include connect and resource)
                3) make changes to the constants below to depict your preferences
                4) set email addresses in spec
                5) Create a ksh file for dg_status

        */
    -- ****************************************************************

    FUNCTION fn_gen_dg_status_ksh (
        p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- add a Y to force an overwrite,
        p_file_name         IN OUT VARCHAR2, -- enter a name if it is different than the default
        p_error_message     IN OUT VARCHAR2                --error message out
                                           )
        RETURN VARCHAR2
    IS
        /*

                Purpose: Create the ksh executable to run all the data guard status

                MODIFICATION HISTORY
                Person      Date        Comments
                ---------   ------      -------------------------------------------
                dcox        19-Feb-2018 Initial Build


        */
        v_line_no            INTEGER := 0;                    -- debug line no
        v_buffer             VARCHAR2 (32767); -- cache buffer into variable for writing
        v_sqlcode            NUMBER;                              -- errorcode
        v_bfile_loc          BFILE; -- binary file location - to test if file exists
        v_file_handle        UTL_FILE.file_type;                -- file handle
        v_filename           VARCHAR2 (400) := vgc_dg_status_ksh_fn; -- executable file to backup rman
        v_rman_file_exists   INTEGER;
        v_directory_name     VARCHAR2 (1000); -- actual directory path to directory

        -- cursor - get directory
        CURSOR c_get_directory (cv_directory IN VARCHAR2)
        IS
            SELECT *
            FROM dba_directories d
            WHERE d.directory_name = cv_directory;

        vrec_directory       c_get_directory%ROWTYPE;
    BEGIN
        v_line_no := 100;                                     -- debug line no

        -- Use default or name provided
        IF p_file_name IS NULL
        THEN
            NULL;                                          -- use default name
        ELSE
            v_filename := p_file_name;
        END IF;
        p_file_name := v_filename;

        v_bfile_loc := BFILENAME (UPPER (vgc_directory), v_filename);
        v_rman_file_exists := DBMS_LOB.fileexists (v_bfile_loc);

        -- Get directory path
        OPEN c_get_directory (vgc_directory);

        FETCH c_get_directory   INTO vrec_directory;

        CLOSE c_get_directory;

        -- Test if file exists
        IF     v_rman_file_exists = 1
           AND (p_force_overwrite != 'Y' OR p_force_overwrite IS NULL)
        THEN
            -- File already exists - create a good error note for end user and exit gracefully

            v_sqlcode := -20001;
            raise_application_error (
                v_sqlcode,
                   'File with directory and name already exist: '
                || vrec_directory.directory_path
                || '/'
                || v_filename);
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
        END IF;

        v_line_no := 150;

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 200;
        v_buffer :=
               '#!/bin/ksh
# file: '
            || v_filename
            || ' USAGE <ORACLE_SID> <DB_UNIQUE_NAME> <target_email_to_replace coded email - null uses existing defaults> '
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || '################'
            || CHR (10)
            || '# Generated by pkg_dg_script_gen.fn_gen_dg_script_gen on '
            || TO_CHAR (SYSDATE, 'dd-MON-yyyy HH24:MI:SS')
            || CHR (10)
            || '################'
            || CHR (10);

        v_buffer :=
               v_buffer
            || '
#
# Purpose:
#
#       Who             Date            Description
#       --------        -----------     -------------------------------
#       dcox            19-Feb-18       rebuild to make this generic and created from generator
#
#
set -x # debug

VERSION="3.0.0"
echo "$VERSION "

# BASE Parameters
SCRIPT_NAME=`basename $0`
export ORACLE_SID=${1} # Node or local SID must be specified
# Notification
export MAIL_TO='
            || vgc_email_to
            || ' # production
export DB_UNIQUE_NAME=${2}
export ALT_MAIL=${3}
export RUN_MAIL_TO='
            || vgc_run_email_to;
        v_buffer :=
               v_buffer
            || 'export SCRIPT_DIR='
            || fn_get_dir_path (vgc_directory)
            || '

# File name for generated html
export DT=$(date +"%Y_%m_%d_%H_%M")

# File name with date attached for file as it becomes an attachment
export SPOOLFILE="data_guard_health_for_${DB_UNIQUE_NAME}"
export SPOOLFILE=${SPOOLFILE}.${DT}
export LOGDIR='
            || fn_get_dir_path (vgc_directory_log)
            || '
export OUTPUT_DIR=${LOGDIR}/output

# Report Name
export REPORT_NAME="Data Guard Health Checks - "
export SQL_SCRIPT_NAME="dg_status.sql"
';

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
            '
################
# FUnctions
################



check_for_fail ()
{
    # check for success
    if [[ ${SUCCESS} != 0 ]]
    then
        echo "Failure on ${SCRIPT_NAME}" | mailx -s "Data Guard Status Check Failed - ${DB_UNIQUE_NAME} -- `hostname` " ${MAIL_TO}
        rm -f ${LOCKFILE}
        exit 1
    fi # end - check of success
}



display_usage  ()
{

        echo " "
        echo "  Usage: ${SCRIPT_NAME} P1-database instance name P2-email alternate  \n\n"
        echo "  ScriptName - Program name\n"
        echo "  P1 - Database instance - may need to change if this is executed for a different node - DB_NAME"
        echo "  P2 - DB Unique Name - Put full db unique name in this parameter"
        echo "  P3 - EMAIL Alternate - different from default - should use default if at all possible"
        echo " "
        echo "  Version: ${VERSION}\n"
        echo " "
        echo " "
        exit 1
}
';

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);

        v_buffer := '
################
# MAIN
################

# Check Arguments
if [[ "$1" == "" ]] || [[ "$2" == "" ]]
then
  echo " "
  echo "Error : missing argument"
  display_usage;
elif [[ "$1" == "-h" ]]
then
    # requesting usage
    display_usage;
else
    echo "Database-P1: ${ORACLE_SID}"
    echo "DB Unique Name-P2: ${DB_UNIQUE_NAME}"
fi
';

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer := '
# Validate email for not empty
if [[ -n ${ALT_MAIL}  ]]
then
        echo "Email Alternate Supplied: ${ALT_MAIL}"
        export MAIL_TO=${ALT_MAIL}
fi

';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
            '
# Create Lock file - Script_DBNAME creates locks file to match
LOCKFILE=${LOGDIR}/${SCRIPT_NAME}_${DB_UNIQUE_NAME}.lockfile; export LOCKFILE
echo "Lockfile: $LOCKFILE \n"

lockfile -r 1 $LOCKFILE
LOCK_RESPONSE=${?}

if [[ $LOCK_RESPONSE -ne 0 ]]
then

    echo "Mail that this file is locked and program not started\n"
    echo "Process already running and locked -  ${SCRIPT_NAME}" | mailx -s "Data Guard Status Check Failed - ${DB_UNIQUE_NAME} -- `hostname`" ${RUN_MAIL_TO}
    # Send standard report - locked - can have different recipients - These always receive a report
    exit 1 # exit with error code
fi

';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer := '


######################
## Set Oracle Home and Path Variables for Scripts
######################

# SET BASE AND HOME PARAMETERS
PATH=/usr/local/bin:$PATH
export PATH
ORAENV_ASK=NO; export ORAENV_ASK
. /usr/local/bin/oraenv

if [[ -z $ORACLE_BASE ]]
then
    echo "ORACLE_BASE is not set\n"
    rm -f ${LOCKFILE}
    exit 1
fi

if [[ -z $ORACLE_HOME ]]
then
    echo "ORACLE_HOME is not set\n"
    rm -f ${LOCKFILE}
    exit 1
fi

echo "Script Parameters"
echo "Oracle SID: ${ORACLE_SID}"
echo "Oracle Base: ${ORACLE_BASE}\n"
echo "Oracle Home: ${ORACLE_HOME}\n"
echo "DB Unique Name: ${DB_UNIQUE_NAME}\n"
echo "Path: ${PATH}\n"
';

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
            '
HTMLMARK="set markup html on spool on entmap off -
    head ''<title>$DB_UNIQUE_NAME $REPORT_NAME</title> -
    <style type="text/css"> -
       table { font-size: 90%; } -
       th { background: #cccc99; } -
       td { padding: 0px; } -
</style>'' -
    body ''text=black bgcolor=fffffff align=left'' -
    table ''align=center width=99% border=3 bordercolor=blue -
    tr:nth-child(even) { -
    background-color: #E4E4E4; -
}''
"

echo "Starting Data Guard Status Check ${DB_UNIQUE_NAME} at `date` \n"
# unset sqlpath to avoid running any other login.sql type scripts
unset SQLPATH

$ORACLE_HOME/bin/sqlplus  "/ as sysdba" <<EOW  # /dev/null
EOW
sqlplus -s /nolog <<EOF
connect / as sysdba
WHENEVER SQLERROR EXIT FAILURE
$HTMLMARK

@${SCRIPT_DIR}/${SQL_SCRIPT_NAME} ${OUTPUT_DIR}/${SPOOLFILE}
EXIT SUCCESS
EOF

SUCCESS=${?}; check_for_fail

cd ${OUTPUT_DIR}


#HTML Mail
## Mail option
if [ "MAIL_TO" != "" ]; then
        echo "Sending report to " ${MAIL_TO}
        (
        echo "Subject: Data Guard Status Check - SID:${DB_UNIQUE_NAME} -- `hostname`";
        echo "To: ${MAIL_TO} "
        echo "MIME-Version: 1.0";
        echo "Content-Type: text/html";
        echo "Content-Disposition: inline";
        cat  ${OUTPUT_DIR}/${SPOOLFILE} ;
        ) | /usr/sbin/sendmail ${MAIL_TO}

fi

# Cleanup
rm -f ${OUTPUT_DIR}/${SPOOLFILE}
SUCCESS=${?}; check_for_fail
';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer := '
rm -f ${LOCKFILE}

exit 0
';
        v_line_no := 10000;                                   -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        v_line_no := 11000;                                   -- debug line no
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 1200;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 13000;                                   -- debug line no
        p_error_message := 'Success';
        RETURN 0;                                                   -- Success
    EXCEPTION
        WHEN UTL_FILE.invalid_path
        THEN
            raise_application_error (
                -20001,
                'INVALID_PATH: File location or filename was
invalid.');
        WHEN UTL_FILE.invalid_mode
        THEN
            raise_application_error (
                -20002,
                'INVALID_MODE: The open_mode parameter in FOPEN was invalid.');
        WHEN UTL_FILE.invalid_filehandle
        THEN
            raise_application_error (
                -20002,
                'INVALID_FILEHANDLE: The file handle was invalid.');
        WHEN UTL_FILE.invalid_operation
        THEN
            raise_application_error (
                -20003,
                'INVALID_OPERATION: The file could not be opened or operated on as requested.');
        WHEN UTL_FILE.read_error
        THEN
            raise_application_error (
                -20004,
                'READ_ERROR: An operating system error occurred during the read operation.');
        WHEN UTL_FILE.write_error
        THEN
            raise_application_error (
                -20005,
                'WRITE_ERROR: An operating system error occurred during the write operation.');
        WHEN UTL_FILE.internal_error
        THEN
            raise_application_error (
                -20006,
                'INTERNAL_ERROR: An unspecified error in PL/SQL.');
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_dg_status_ksh;                 -- function fn_gen_dg_status_ksh

    -- ****************************************************************

    -------------------------------------------

    FUNCTION fn_get_dir_path (p_directory_name IN VARCHAR2   -- Directory Name
                                                          )
        RETURN VARCHAR2
    IS
        /*
            Purpose: Get's the Directory path for the given directory name

            MODIFICATION HISTORY
            Person      Date        Comments
            ---------   ------      -------------------------------------------
            dcox        11/5/2015    Initial Build
            dcox        08-Jan-18   rebuild to make this generic
        */
        v_dir_path   VARCHAR2 (4000);                  -- sid for the database
    BEGIN
        SELECT directory_path
        INTO v_dir_path
        FROM all_directories
        WHERE directory_name = p_directory_name;

        RETURN v_dir_path;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END fn_get_dir_path;                           -- Function fn_get_dir_path

    ------------------------------------------------------
    FUNCTION fn_gen_dg_status_sql (
        p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- add a Y to force an overwrite,
        p_file_name         IN OUT VARCHAR2, -- enter a name if it is different than the default
        p_error_message     IN OUT VARCHAR2                --error message out
                                           )
        RETURN VARCHAR2
    IS
        /*

                       Purpose: Create the sql script to run all the data guard status

                       MODIFICATION HISTORY
                       Person      Date        Comments
                       ---------   ------      -------------------------------------------
                       dcox        19-Feb-2018 Initial Build


               */
        v_line_no            INTEGER := 0;                    -- debug line no
        v_buffer             VARCHAR2 (32767); -- cache buffer into variable for writing
        v_sqlcode            NUMBER;                              -- errorcode
        v_bfile_loc          BFILE; -- binary file location - to test if file exists
        v_file_handle        UTL_FILE.file_type;                -- file handle
        v_filename           VARCHAR2 (400) := vgc_dg_status_sql_fn; -- executable file to backup rman
        v_rman_file_exists   INTEGER;
        v_directory_name     VARCHAR2 (1000); -- actual directory path to directory
    BEGIN
        v_line_no := 100;                                     -- debug line no

        -- Use default or name provided
        IF p_file_name IS NULL
        THEN
            NULL;                                          -- use default name
        ELSE
            v_filename := p_file_name;
        END IF;

        v_bfile_loc := BFILENAME (UPPER (vgc_directory), v_filename);
        v_rman_file_exists := DBMS_LOB.fileexists (v_bfile_loc);

        -- Test if file exists
        IF     v_rman_file_exists = 1
           AND (p_force_overwrite != 'Y' OR p_force_overwrite IS NULL)
        THEN
            -- File already exists - create a good error note for end user and exit gracefully

            v_sqlcode := -20001;
            raise_application_error (
                v_sqlcode,
                   'File with directory and name already exist: '
                || fn_get_dir_path (vgc_directory)
                || '/'
                || v_filename);
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
        END IF;

        v_line_no := 150;

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 200;
        v_buffer :=
            '
    /*
-------------
-- From Note 1577406.1
-- Copied on 12/9/13 David Cox
-- Modified 12/31/13 David Cox
----------------------------------------------------------------
*/
set echo off
set feedback off
column timecol new_value timestamp
column spool_extension new_value suffix
select to_char(sysdate,''Mondd_hhmi'') timecol, ''.html'' spool_extension from sys.dual;
column output new_value dbname
select value || ''_'' output
from v$parameter where name = ''db_unique_name'';
spool &1
set linesize 2000
set pagesize 50000
set numformat 999999999999999
set trim on
set trims on
set markup html on
set markup html entmap off

ALTER SESSION SET nls_date_format = ''DD-MON-YYYY HH24:MI:SS'';
SELECT TO_CHAR(sysdate) time FROM dual;

SELECT ''The following select will give us the generic information about how this standby is setup.<br>The DATABASE_ROLE should be STANDBY as that is what this script is intended to be run on.<br>PLATFORM_ID should match the PLATFORM_ID of the primary or conform to the supported options in<br>Note: 413484.1 Data Guard Support for Heterogeneous Primary and Physical Standbys in Same Data Guard Configuration.<br>FLASHBACK can be YES (recommended) or NO.<br>If PROTECTION_LEVEL is different from PROTECTION_MODE then for some reason the mode listed in PROTECTION_MODE experienced a need to downgrade.<br>Once the error condition has been corrected the PROTECTION_LEVEL should match the PROTECTION_MODE after the next log switch.'' "Database 1" FROM dual;

SELECT database_role role, name, db_unique_name, platform_id, open_mode, log_mode, flashback_on, protection_mode, protection_level FROM v$database;

SELECT ''FORCE_LOGGING is not mandatory but is recommended.<br>REMOTE_ARCHIVE should be ENABLE.<br>SUPPLEMENTAL_LOG_DATA_PK and SUPPLEMENTAL_LOG_DATA_UI must be enabled if this standby is associated with a primary that has a logical standby.<br>During normal operations it is acceptable for SWITCHOVER_STATUS to be NOT ALLOWED.<br>DATAGUARD_BROKER can be ENABLED (recommended) or DISABLED.'' "Database 2" FROM dual;

column force_logging format a13 tru
column supplemental_log_data_pk format a24 tru
column supplemental_log_data_ui format a24 tru

SELECT force_logging, remote_archive, supplemental_log_data_pk, supplemental_log_data_ui, switchover_status, dataguard_broker  FROM v$database;

SELECT ''Check how many threads are enabled and started for this database. If the number of instances below does not match then not all instances are up.'' "Threads" FROM dual;

SELECT thread#, instance, status FROM v$thread;

SELECT ''The number of instances returned below is the number currently running.  If it does not match the number returned in Threads above then not all instances are up.<br>VERSION should match the version from the primary database.<br>ARCHIVER can be (STOPPED | STARTED | FAILED). FAILED means that the archiver failed to archive a log last time, but will try again within 5 minutes.<br>LOG_SWITCH_WAIT the ARCHIVE LOG/CLEAR LOG/CHECKPOINT event log switching is waiting for.<br>Note that if ALTER SYSTEM SWITCH LOGFILE is hung, but there is room in the current online redo log, then the value is NULL.'' "Instances" FROM dual;

column host_name format a32 wrap

SELECT thread#, instance_name, host_name, version, archiver, log_switch_wait FROM gv$instance ORDER BY thread#;

SELECT ''Check the number and size of online redo logs on each thread.'' "Online Redo Logs" FROM dual;

set feedback on

SELECT thread#, group#, sequence#, bytes, archived ,status FROM v$log ORDER BY thread#, group#;

set feedback off

SELECT ''The following query is run to see if standby redo logs have been created.<br>The standby redo logs should be the same size as the online redo logs.<br>There should be (( # of online logs per thread + 1) * # of threads) standby redo logs.<br>A value of 0 for the thread# means the log has never been allocated.'' "Standby Redo Logs" FROM dual;

set feedback on

SELECT thread#, group#, sequence#, bytes, archived, status FROM v$standby_log order by thread#, group#;

set feedback off

SELECT ''This query produces a list of defined archive destinations. It shows if they are enabled, what process is servicing that destination, if the destination is local or remote, and if remote what the current mount ID is.<br>For a physical standby we should have at least one remote destination that points the primary set.'' "Archive Destinations" FROM dual;

column destination format a35 wrap
column process format a7
column ID format 99
column mid format 99

SELECT thread#, dest_id, destination, gvad.status, target, schedule, process, mountid mid FROM gv$archive_dest gvad, gv$instance gvi WHERE gvad.inst_id = gvi.inst_id AND destination is NOT NULL ORDER BY thread#, dest_id;

SELECT ''If the protection mode of the standby is set to anything higher than max performance then we need to make sure the remote destination that points to the primary is set with the correct options else we will have issues during switchover.'' "Archive Destination Options" FROM dual;

set numwidth 8
column archiver format a8
column ID format 99
column error format a55 wrap

SELECT thread#, dest_id, gvad.archiver, transmit_mode, affirm, async_blocks, net_timeout, delay_mins, reopen_secs reopen, register, binding FROM gv$archive_dest gvad, gv$instance gvi WHERE gvad.inst_id = gvi.inst_id AND destination is NOT NULL ORDER BY thread#, dest_id;

SELECT ''The following select will show any errors that occured the last time an attempt to archive to the destination was attempted.<br>If ERROR is blank and status is VALID then the archive completed correctly.'' "Archive Destination Errors" FROM dual;

SELECT thread#, dest_id, gvad.status, error FROM gv$archive_dest gvad, gv$instance gvi WHERE gvad.inst_id = gvi.inst_id AND destination is NOT NULL ORDER BY thread#, dest_id;

SELECT ''The query below will determine if any error conditions have been reached by querying the v$dataguard_status view (view only available in 9.2.0 and above).'' "Data Guard Status" FROM dual;

column message format a80

set feedback on

SELECT timestamp, gvi.thread#, message FROM gv$dataguard_status gvds, gv$instance gvi WHERE gvds.inst_id = gvi.inst_id AND severity in (''Error'',''Fatal'') ORDER BY timestamp, thread#;

set feedback off

SELECT ''Query v$managed_standby to see the status of processes involved in the shipping redo on this system.<br>Does not include processes needed to apply redo.'' "Managed Standby Status" FROM dual;

SELECT inst_id, thread#, process, pid, status, client_process, client_pid, sequence#, block#, active_agents, known_agents FROM gv$managed_standby ORDER BY thread#, pid;

SELECT ''Verify the last sequence# received and the last sequence# applied to standby database.'' "Last Sequence Received/Applied" FROM dual;

SELECT al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied" FROM (select thread# thrd, MAX(sequence#) almax FROM v$archived_log WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v$database) GROUP BY thread#) al, (SELECT thread# thrd, MAX(sequence#) lhmax FROM v$log_history WHERE resetlogs_change#=(SELECT resetlogs_change# FROM v$database) GROUP BY thread#) lh WHERE al.thrd = lh.thrd;

SELECT ''Check the transport lag and apply lag from the V$DATAGUARD_STATS view.  This is only relevant when LGWR log transport and real time apply are in use.'' "Standby Lag" FROM dual;

SELECT * FROM v$dataguard_stats WHERE name LIKE ''%lag%'';

SELECT ''The V$ARCHIVE_GAP fixed view on a physical standby database only returns the next gap that is currently blocking redo apply from continuing.<br>After resolving the identified gap and starting redo apply, query the V$ARCHIVE_GAP fixed view again on the physical standby database to determine the next gap sequence, if there is one.'' "Archive Gap" FROM dual;

SELECT * FROM v$archive_gap;

SELECT ''Non-default init parameters.<br>For a RAC DB Thread# = * means the value is the same for all threads (SID=*)<br>Threads with different values are shown with their individual thread# and values.'' "Non Default init Parameters" FROM dual;

column num noprint

SELECT num, ''*'' "THREAD#", name, value FROM v$PARAMETER WHERE NUM IN (SELECT num FROM v$parameter WHERE isdefault = ''FALSE''
MINUS
SELECT num FROM gv$parameter gvp, gv$instance gvi WHERE num IN (SELECT DISTINCT gvpa.num FROM gv$parameter gvpa, gv$parameter gvpb WHERE gvpa.num = gvpb.num AND  gvpa.value <> gvpb.value AND gvpa.isdefault = ''FALSE'') AND gvi.inst_id = gvp.inst_id  AND gvp.isdefault = ''FALSE'')
UNION
SELECT num, TO_CHAR(thread#) "THREAD#", name, value FROM gv$parameter gvp, gv$instance gvi WHERE num IN (SELECT DISTINCT gvpa.num FROM gv$parameter gvpa, gv$parameter gvpb WHERE gvpa.num = gvpb.num AND  gvpa.value <> gvpb.value AND gvpa.isdefault = ''FALSE'') AND gvi.inst_id = gvp.inst_id  AND gvp.isdefault = ''FALSE'' ORDER BY 1, 2;

-- this will fail on standby
whenever sqlerror continue

select ''Verify there is enough space in the recovery file destination and that backups are clearing this out regularly'' "DB Recovery Destination Sizes" from dual;

column name format a20

SELECT name,
       ROUND(
             space_limit / (1024 * 1024 * 1024),
             3
            )
           gb_space_limit,
       ROUND(
             space_used / (1024 * 1024 * 1024),
             3
            )
           gb_space_used,
       ROUND(
             space_reclaimable / (1024 * 1024 * 1024),
             3
            )
           gb_space_reclaimable,
       ROUND(
             100 * (space_used / space_limit),
             2
            )
           pct_used
FROM   v$recovery_file_dest;

spool off
set markup html off entmap on
set feedback on
set echo on

exit 0;

';
        v_line_no := 10000;                                   -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        v_line_no := 11000;                                   -- debug line no
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 1200;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 13000;                                   -- debug line no
        p_error_message := 'Success';
        RETURN 0;                                                   -- Success
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END;
END pkg_dg_script_gen;                       -- Package body pkg_dg_script_gen
/
