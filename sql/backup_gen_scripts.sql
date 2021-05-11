-- Start of DDL Script for Package PXDDBA.PKG_RMAN_SCRIPT_GEN
-- Generated 04-Mar-2018 10:59:04 from PXDDBA@DBATOOLS

CREATE OR REPLACE 
PACKAGE        pxddba.pkg_rman_script_gen
/* Formatted on 1/14/2018 7:52:08 PM (QP5 v5.309) */
IS
    /*

                        Purpose: Generate scripts for rman backups

            MODIFICATION HISTORY
            Version     Person      Date        Comments
            --------    ---------   ------      -------------------------------------------
            3.0.0       dcox        01/05/18    Creating Generic version - Pulled from previous versions to make a generic version

            Instructions:
            1) Install this package and get it to compile
                Use the following notes:
                    NOTES- example scripts for directory creation (Change -- to REM or remove comments if you run from Sql*Plus)
                    -- All scripts for rman here
                    create or replace directory rman_scripts as '/home/oracle/dba/bin/rman';
                    -- All logs for rman here
                    create or replace directory rman_logs as '/home/oracle/dba/bin/rman/log';
                    -- permissions
                    grant read,write on directory rman_scripts to <packageOwner>;
                    -- permissions
                    grant read,write on directory rman_logs to <packageOwner>;

                    -- grant to pkg owner
                    grant select on gv_$instance to <packageOwner>;
                    -- grant to pkg owner
                    grant select on v_$database to <packageOwner>;
                    -- grant to pkg owner
                    grant select on v_$instance to <packageOwner>;
                    -- grant to pkg owner
                    grant select on dba_directories to <packageOwner>;
                    Exclude these for now:
                    -- rmanbackup - this password goes in sys_utility file
                    -- create user <rman_backup_user below> identified by <PASSWORD>;
                    -- needs this priviledge to run rman backups
                    -- grant sysbackup to <rman_backup_backup_user>;
            2) Make sure the owner to this package has connect, resource and DBA (note DBA may include connect and resource)
            3) make changes to the constants below to depict your preferences
            4) Look through code of fn_gen_rman_ksh_master and set email addresses
            5) Create a ksh file for backups
            6) Create the file "sys_utility.rman" in the rman_scripts directory with a password for the channels
                > echo "PasswordforChannels" > sys_utility.rman # Add password
                > chmod 740 sys_utility.rman # change permissions to only user and group read

     -- Repeat below steps for each database
            7) run p_create_standard_channels (or standby)
            8) Add execute permissions ksh file created and run to create services
            9) run the file_to_create_bkupsvc script and create the services file
            10) register database with recovery catalog if exists
                rman target / catalog rman/cat@catdb
                rman> register database
            11) make sure /etc/oratab on all nodes has <dbname> and <dbname><instno>
            12) Make directories on target file system mkdir "vgc_head1_dir_prefix/DBNAME"

        If you have multiple environments, you may want to have multiple copies of this procedure - one for each environment - can be in same db if you change names.

    */
    -- Database Constants
    vgc_default_backup_rman        CONSTANT VARCHAR2 (200) := 'backup_rman.ksh'; -- default name for backup file
    vgc_email_success              CONSTANT VARCHAR2 (2000) := 'david.cox2@pxd.com,arun.yadav@pxd.com,cody.fincher@pxd.com,jacob.walsh@pxd.com,Chethan.Varattodi@pxd.com,Tanaji.Tone@pxd.com,Kasetti.Ramesh@pxd.com,Dhanapal.Palanisamy@pxd.com,Sanjeevi.NaiduKaligi@pxd.com,Anoop.Kumar@pxd.com,Mohit.Garg@pxd.com,Nagarajan.Chinnakani@pxd.com'; -- success email(s) - comma seperated if more than one
    vgc_email_failure              CONSTANT VARCHAR2 (2000) := 'david.cox2@pxd.com,arun.yadav@pxd.com,cody.fincher@pxd.com,jacob.walsh@pxd.com,Chethan.Varattodi@pxd.com,Tanaji.Tone@pxd.com,Kasetti.Ramesh@pxd.com,Dhanapal.Palanisamy@pxd.com,Sanjeevi.NaiduKaligi@pxd.com,Anoop.Kumar@pxd.com,Mohit.Garg@pxd.com,Nagarajan.Chinnakani@pxd.com'; -- failure email(s) - comma seperated if more than one
    vgc_email_report               CONSTANT VARCHAR2 (2000) := 'david.cox2@pxd.com,arun.yadav@pxd.com,cody.fincher@pxd.com,jacob.walsh@pxd.com,Chethan.Varattodi@pxd.com,Tanaji.Tone@pxd.com,Kasetti.Ramesh@pxd.com,Dhanapal.Palanisamy@pxd.com,Sanjeevi.NaiduKaligi@pxd.com,Anoop.Kumar@pxd.com,Mohit.Garg@pxd.com,Nagarajan.Chinnakani@pxd.com'; -- report email(s) - comma seperated if more than one
    vgc_rman_backup_user           CONSTANT VARCHAR2 (30) := 'SYS'; -- user used to connect channels for rman backup
    vgc_base_retention_days        CONSTANT INTEGER := 16; -- number of days to keep daily and weekly
    vgc_cleanup_after_days         CONSTANT INTEGER := 30; -- number of days after which to clean up lingering backup files
    vgc_channel_upper_limit        CONSTANT INTEGER := 24; -- channel upper limit ( vgc_channel_upper_limit/compute nodes  should be an integer)
    vgc_directory                  CONSTANT VARCHAR2 (200) := 'RMAN_SCRIPTS'; -- directory where rman command scripts are kept
    vgc_directory_logs             CONSTANT VARCHAR2 (200) := 'RMAN_LOGS'; -- directory where rman command scripts are kept for monthly's
    vgc_compressed_default         CONSTANT VARCHAR2 (1) := 'Y'; -- Y)es or N)o to backup compression
    vgc_arclog_del_policy_days     CONSTANT INTEGER := 2; -- number of days to keep archivelogs online in reco
    vgc_archive_logfile_switches   CONSTANT INTEGER := 3; -- number of archive logfile switches before backup
    vgc_catalog_user_pwd           CONSTANT VARCHAR2 (100)
                                                := 'rman/T3Aq30vjQG@rman' ; -- Catalog uid/pwd@db
    vgc_bool_skip_rman_backup_cf constant boolean := FALSE; -- turn this to true on systems that have a bug on this option - cf backups are very redundant
    vgc_filesperset_all            CONSTANT INTEGER := 1; -- filesperset - generic setting for backups and archivelogs all levels - may want to tune
    vgc_default_asm_data           CONSTANT VARCHAR2 (300) := 'DATAC1'; -- default asm data group
    vgc_default_asm_reco           CONSTANT VARCHAR2 (300) := 'RECOC1'; -- default asm data group
    vgc_compute_nodes              CONSTANT INTEGER := 2; -- compute nodes (default)
    vgc_oracle_base                CONSTANT VARCHAR2 (300)
                                                := '/u01/app/oracle' ; -- oracle base
    vgc_oracle_home                CONSTANT VARCHAR2 (300)
        := '/u01/app/oracle/product/12.1.0.2/dbhome_1' ;        -- oracle home

    -- Head prefixes can be the same for non-zfs application - or you can create 2 locations on a remote nas
    vgc_zfs_bool                   CONSTANT BOOLEAN := FALSE; -- true for zfs and false for non-zfs - Does not add 01,02,... postfix(s) on head_dir_prefix for non-zfs
    vgc_head1_dir_prefix           CONSTANT VARCHAR2 (200)
                                                := '/ora1/oracle/backup3' ; -- Head 1 path
    vgc_head2_dir_prefix           CONSTANT VARCHAR2 (200)
                                                := '/ora1/oracle/backup3' ; -- Head 2 path

    vgc_scan_address               CONSTANT VARCHAR2 (200) := 'examid-scan'; -- scan address

    ---------------------------------------------------------------------------------------------------






















      FUNCTION fn_gen_bkup_services (
          p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
          p_db_name              IN     VARCHAR2,            -- Database DB_NAME
          p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
          p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
          p_buffer               IN OUT VARCHAR2,        -- services list buffer
          p_error_message        IN OUT VARCHAR2                -- error message
                                                )
          RETURN NUMBER;

      FUNCTION fn_gen_bkup_services_ss (
          p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
          p_db_name              IN     VARCHAR2,            -- Database DB_NAME
          p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
          p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
          p_buffer               IN OUT VARCHAR2,        -- services list buffer
          p_error_message        IN OUT VARCHAR2                -- error message
                                                )
          RETURN NUMBER;

      FUNCTION fn_gen_file_to_create_bkupsvc (
          p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
          p_db_name              IN     VARCHAR2,            -- Database DB_NAME
          p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
          p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
          p_error_message        IN OUT VARCHAR2                -- error message
                                                )
          RETURN NUMBER;

      FUNCTION fn_gen_file_to_ss_bkupsvc (
          p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
          p_db_name              IN     VARCHAR2,            -- Database DB_NAME
          p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
          p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
          p_error_message        IN OUT VARCHAR2                -- error message
                                                )
          RETURN NUMBER;

      FUNCTION fn_gen_rcvr_local_with_s_c (
          p_dbid                IN     VARCHAR2, -- DB ID from original DB (if it is to be set the same (null if not setting this)
          p_db_name             IN     VARCHAR2, -- Database NAME - Matching /zfssa/.../backupxx/<DB_NAME> - you can change later if needed or modify scripts
          p_db_unique_name      IN     VARCHAR2,         -- Database UNIQUE NAME
          p_oracle_base         IN     VARCHAR2,                  -- ORACLE_BASE
          p_oracle_home         IN     VARCHAR2,                  -- ORACLE_HOME
          p_db_instance_name    IN     VARCHAR2, -- instance name and number to be started on initial machine
          p_compute_nodes       IN     INTEGER,       -- number of compute nodes
          p_previous_asm_data   IN     VARCHAR2, -- previous DATA ASM disk group (like +DATA_DM) - Auxiliary
          p_current_asm_data    IN     VARCHAR2, -- current  DATA ASM disk group (like +DATA_WH) - Target
          p_previous_asm_reco   IN     VARCHAR2, -- previous RECO ASM disk group (like +RECO_DM) - Auxiliary
          p_current_asm_reco    IN     VARCHAR2, -- current  RECO ASM disk group (like +RECO_WH) - Target
          p_machine_name_1      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_2      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_3      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_4      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_5      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_6      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_7      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_machine_name_8      IN     VARCHAR2, -- machine name (adm name for db compute node)
          p_error_message       IN OUT VARCHAR2 -- If there is an error message (return code less than zero - then return message)
                                               )
          RETURN NUMBER;

      FUNCTION fn_gen_rman_backup_ext (
          p_database           IN     VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
          p_level              IN     INTEGER, -- Backup Level 0-Full, 1-9 -- incremental level
          p_channels           IN     INTEGER, -- Channels 1-vgc_channel_upper_limit
          p_compressed         IN     VARCHAR2, -- Y)es or N)o - null will default to No
          p_head1_dir_prefix   IN     VARCHAR2,                -- path to head 1
          p_head2_dir_prefix   IN     VARCHAR2,                -- path to head 2
          p_date               IN     DATE DEFAULT NULL, -- Date provided for Monthly backups only - will force to a full
          p_catalog            IN     VARCHAR2 DEFAULT NULL, -- Default is Y)es - N)o to stop adding catalog entry
          p_filename           IN OUT VARCHAR2,   -- filename for monthly script
          p_error_message      IN OUT VARCHAR2     -- error message (or Success)
                                              )
          RETURN NUMBER;

      FUNCTION fn_gen_rman_backup_file (
          p_database        IN     VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
          p_level           IN     INTEGER, -- Backup Level 0-Full, 1-9 -- incremental level
          p_channels        IN     INTEGER, -- Channels 1-vgc_channel_upper_limit
          p_compressed      IN     VARCHAR2, -- Y)es or N) - null will default to Yes
          p_catalog         IN     VARCHAR2 DEFAULT NULL, -- Default is N)o Y)esto stop adding catalog entry
          p_filename        IN OUT VARCHAR2,      -- filename for monthly script
          p_error_message   IN OUT VARCHAR2        -- error message (or Success)
                                           )
          RETURN NUMBER;

      FUNCTION fn_gen_rman_backup_file_stby (
          p_db_unique_name   IN     VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
          p_level            IN     INTEGER, -- Backup Level 0-Full, 1-9 -- incremental level
          p_channels         IN     INTEGER, -- Channels 1-vgc_channel_upper_limit
          p_compressed       IN     VARCHAR2, -- Y)es or N) - null will default to Yes
          p_catalog          IN     VARCHAR2 DEFAULT NULL, -- Default is N)o - Yes to add catalog entry
          p_filename         IN OUT VARCHAR2,     -- filename for monthly script
          p_error_message    IN OUT VARCHAR2       -- error message (or Success)
                                            )
          RETURN NUMBER;

      FUNCTION fn_gen_rman_ksh_master (
          p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- add a Y to force an overwrite,
          p_file_name         IN OUT VARCHAR2, -- enter a name if it is different than the default
          p_error_message     IN OUT VARCHAR2                --error message out
                                             )
          RETURN VARCHAR2;

      FUNCTION fn_gen_rman_ksh_status (
          p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- 'Y'  in this will overwrite
          p_error_message     IN OUT VARCHAR2                --error message out
                                             )
          RETURN VARCHAR2;



      FUNCTION fn_get_dbun
          RETURN VARCHAR2;

      FUNCTION fn_get_dir_path (p_directory_name IN VARCHAR2   -- Directory Name
                                                            )
          RETURN VARCHAR2;

      FUNCTION fn_get_instance_count
          RETURN NUMBER;




      PROCEDURE p_ksh_gen_base_directories (p_notes            IN VARCHAR2 DEFAULT NULL, -- writes notes to header
                                            p_db_unique_name   IN VARCHAR2 -- Database UNIQUE NAME
                                                                          );

      FUNCTION fn_gen_rman_maint_file (
          p_db_unique_name   IN     VARCHAR2 DEFAULT NULL,     -- DB UNIQUE NAME
          p_catalog          IN     VARCHAR2 DEFAULT NULL, -- Default is N)o,  Y)es to add catalog entry
          p_filename         IN OUT VARCHAR2, -- filename for maintenance script
          p_error_message    IN OUT VARCHAR2       -- error message (or Success)
                                            )
          RETURN NUMBER;

      FUNCTION fn_gen_rman_maint_file_stby (
          p_db_unique_name   IN     VARCHAR2 DEFAULT NULL,     -- DB UNIQUE NAME
          p_catalog          IN     VARCHAR2 DEFAULT NULL, -- Default is N)o,  Y)es to add catalog entry
          p_filename         IN OUT VARCHAR2, -- filename for maintenance script
          p_error_message    IN OUT VARCHAR2       -- error message (or Success)
                                            )
          RETURN NUMBER;

      PROCEDURE p_create_standard_channels (
          p_db_unique_name   IN VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
          p_catalog          IN VARCHAR2 DEFAULT NULL, -- Default is N)o - Y)es to add catalog
          p_channels_max     IN VARCHAR2 DEFAULT NULL -- Desired maximum number of channels needed
                                                     );

      PROCEDURE p_create_standby_channels (
          p_db_unique_name   IN VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
          p_db_name          IN VARCHAR2 DEFAULT NULL,                -- DB NAME
          p_channels_max     IN VARCHAR2 DEFAULT NULL -- Desired maximum number of channels needed
                                                     );
END pkg_rman_script_gen;
/

-- Grants for Package
GRANT EXECUTE ON pxddba.pkg_rman_script_gen TO sys
/

CREATE OR REPLACE 
PACKAGE BODY        pxddba.pkg_rman_script_gen
/* Formatted on 2/27/2018 10:39:16 PM (QP5 v5.309) */
IS
    /*

                         Purpose: Generate scripts for rman backups

             MODIFICATION HISTORY
             Version     Person      Date        Comments
             --------    ---------   ------      -------------------------------------------
             3.0.0       dcox        01/05/18    Creating Generic version - Pulled from previous versions to make a generic version
             3.0.1       dcox        2/12/18     Added more code for standby
                         dcox        2/26/18     Added modified fn_gen_rman_ksh_master

             Instructions:
             1) Install this package and get it to compile
                 Use the following notes:
                     NOTES- example scripts for directory creation (Change -- to REM or remove comments if you run from Sql*Plus)
                     -- All scripts for rman here
                     create or replace directory rman_scripts as '/home/oracle/dba/bin/rman';
                     -- All logs for rman here
                     create or replace directory rman_logs as '/home/oracle/dba/bin/rman/log';
                     -- permissions
                     grant read,write on directory rman_scripts to <packageOwner>;
                     -- permissions
                     grant read,write on directory rman_logs to <packageOwner>;

                     -- grant to pkg owner
                     grant select on gv_$instance to <packageOwner>;
                     -- grant to pkg owner
                     grant select on v_$database to <packageOwner>;
                     -- grant to pkg owner
                     grant select on v_$instance to <packageOwner>;
                     -- grant to pkg owner
                     grant select on dba_directories to <packageOwner>;
                     Exclude these for now:
                     -- rmanbackup - this password goes in sys_utility file
                     -- create user <rman_backup_user below> identified by <PASSWORD>;
                     -- needs this priviledge to run rman backups
                     -- grant sysbackup to <rman_backup_backup_user>;
             2) Make sure the owner to this package has connect, resource and DBA (note DBA may include connect and resource)
             3) make changes to the constants below to depict your preferences
             4) Look through code of fn_gen_rman_ksh_master and set email addresses
             5) Create a ksh file for backups
             6) Create the file "sys_utility.rman" in the rman_scripts directory with a password for the channels
                 > echo "PasswordforChannels" > sys_utility.rman # Add password
                 > chmod 740 sys_utility.rman # change permissions to only user and group read

      -- Repeat below steps for each database
             7) run p_create_standard_channels
             8) Add execute permissions ksh file created and run to create services
             9) run the file_to_create_bkupsvc script and create the services file
             10) register database with recovery catalog if exists
                 rman target / catalog rman/cat@catdb
                 rman> register database
             11) make sure /etc/oratab on all nodes has <dbname> and <dbname><instno>
             12) Make directories on target file system mkdir "vgc_head1_dir_prefix/DBNAME"

      -- Tasks for Standby (non-Data Guard)
         7) run p_create_standby_channels
         8) Add execute permissions ksh file created and run to create service
         9) On Primary > RMAN>  CONFIGURE DB_UNIQUE_NAME 'dgtstc_SBY' CONNECT IDENTIFIER  'dgtstc_SBY';
         10) Check with: RMAN> LIST DB_UNIQUE_NAME OF DATABASE;
             Example Output:
                 List of Databases
                 DB Key  DB Name  DB ID            Database Role    Db_unique_name
                 ------- ------- ----------------- ---------------  ------------------
                 238896  DGTSTC   1753684957       PRIMARY          DGTSTC
                 238896  DGTSTC   1753684957       STANDBY          DGTSTC_SBY
         11)


 If you have multiple environments, you may want to have multiple copies of this procedure - one for each environment - can be in same db if you change names.

     */

    FUNCTION fn_get_sys_utility
        RETURN VARCHAR2
    IS
        /*

                   Purpose: Gets SYS parameter to make backups work

                   This should not be a public function (private only)

                   Assumes this is teh same across all databases using this functionality.

                   Will have to re-work this if this is not true.

                   MODIFICATION HISTORY
                   Person      Date        Comments
                   ---------   ------      -------------------------------------------
                   dcox        10/15/2015    Initial Build
                   dcox        08-Jan-18   rebuild to make this generic

           */
        v_line_no             INTEGER := 0;                   -- debug line no
        v_utility_parameter   VARCHAR2 (200);             -- utility parameter
        v_file_handle         UTL_FILE.file_type;               -- file handle
        vc_file_name          VARCHAR2 (200) := 'sys_utility.rman'; -- sys utility file name
        v_buffer              VARCHAR2 (32767);      -- Write buffer for files
    BEGIN
        v_line_no := 100;                                     -- debug line no
        -- Open directory/file
        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => vc_file_name,
                            open_mode      => 'r',
                            max_linesize   => 32000);
        v_line_no := 200;                                     -- debug line no
        -- read parameter
        UTL_FILE.get_line (file => v_file_handle, buffer => v_buffer);

        v_utility_parameter := v_buffer;
        UTL_FILE.fclose (file => v_file_handle);
        -- return parameter
        RETURN v_utility_parameter;
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            RAISE;
    END fn_get_sys_utility;

    ------------------------------------------

    FUNCTION fn_gen_rman_backup_file (
        p_database        IN     VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
        p_level           IN     INTEGER, -- Backup Level 0-Full, 1-9 -- incremental level
        p_channels        IN     INTEGER, -- Channels 1-vgc_channel_upper_limit
        p_compressed      IN     VARCHAR2, -- Y)es or N) - null will default to Yes
        p_catalog         IN     VARCHAR2 DEFAULT NULL, -- Default is N)o Y)esto stop adding catalog entry
        p_filename        IN OUT VARCHAR2,      -- filename for monthly script
        p_error_message   IN OUT VARCHAR2        -- error message (or Success)
                                         )
        RETURN NUMBER
    IS
        /*

                    Purpose: Generate command script for rman backups

                    This is for a 2 head ZFS with services

                    MODIFICATION HISTORY
                    Person      Date        Comments
                    ---------   ------      -------------------------------------------
                    dcox        10/15/2015    Initial Build
                    dcox        10/25/2015  Moved monthly command files to .../rman/log
                    dcox        10/29/2015  Added Reuse for controlfile backup
                    dcox        11/10/2015  Added LF after "consistency"
                    dcox        11/13/2015  Added backup controlfile to trace
                    dcox        11/25/2015  Added parameter and clause to exclude catalog
                    dcox        12/2/2015   Added "delete noprompt archivelog all backed up xx times to disk;"
                    dcox        12/4/2015   Put catalog user password in global variable in spec
                    dcox        08-Jan-18   rebuild to make this generic

            */
        vc_backup_file_size   CONSTANT INTEGER := 32; -- Backup File Size in Gb (suggested 32)
        v_code_backup_and_close        VARCHAR2 (32767); -- backup statement and close of command file
        v_tag                          VARCHAR2 (100);           -- Backup Tag

        v_level                        INTEGER;                -- Backup Level
        v_channels                     INTEGER;          -- number of channels
        v_channel_no                   VARCHAR2 (4); -- actual left padded channel number ( for Looping - incremented)
        v_channel_no_max               VARCHAR2 (4); -- actual left padded channel number - static for output
        v_code_filename                VARCHAR2 (32767); -- name to be placed into code for the filename
        v_code_change_block            VARCHAR2 (32767);  -- code change block
        v_code_catalog_connect         VARCHAR2 (32767); -- code for catalog connect string
        v_code_echo_on                 VARCHAR2 (32767); -- code for echo statement
        v_code_run_and_settings        VARCHAR2 (32767); -- code for database settings to optimize rman
        v_code_allocate_channels       VARCHAR2 (32767); -- code to be used to allocate channels
        v_sys_pwd                      VARCHAR2 (100); -- password for SYS to be used in code creation
        v_sqlcode                      NUMBER;                   -- error code

        v_database                     VARCHAR2 (20); -- uppercase database name
        v_directory                    VARCHAR2 (200); -- directory to write rman file
        v_filename                     VARCHAR2 (2000); -- physical filename where code will be written
        v_file_handle                  UTL_FILE.file_type;      -- file handle
        v_buffer                       VARCHAR2 (32767); -- Write buffer for files
        v_sys_util_param               VARCHAR2 (200); -- sys utility parameter
        v_line_no                      INTEGER := 0;          -- debug line no
        v_compressed                   VARCHAR2 (200); -- used when p_compressed is null or 'Y'
    ------------------------------------------------------------------------------------------

    BEGIN
        v_line_no := 100;                                     -- debug line no

        -------------------------
        -- get fn_get_sys_utility
        BEGIN
            v_sys_util_param := fn_get_sys_utility;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (-20001,
                                         'sys_utility file not found');
        END;

        --------------------------
        -- Validate level
        IF p_level BETWEEN 0 AND 9
        THEN
            v_level := p_level;
        ELSE
            raise_application_error (-20001, 'Level is not between 0 and 9');
        END IF;

        -- Validate channels
        IF p_channels BETWEEN 1 AND vgc_channel_upper_limit
        THEN
            v_channels := p_channels;
            v_channel_no_max := LPAD (v_channels, 2, '0'); -- left padded integer
        ELSE
            raise_application_error (
                -20002,
                   'Channels is not between 1 and '
                || vgc_channel_upper_limit
                || '.');
        END IF;

        v_line_no := 150;                                     -- debug line no

        -- Check for database name
        IF p_database IS NOT NULL
        THEN
            v_database := UPPER (p_database);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        -- Check for compression
        IF SUBSTR (p_compressed, 1, 1) = 'Y' OR p_compressed IS NULL
        THEN
            v_compressed := ' compressed ';
        END IF;

        v_line_no := 300;                                     -- debug line no
        ----------------
        -- Compose Filename
        v_filename :=
            LOWER (
                   'backup_'
                || v_database
                || '_'
                || v_channel_no_max
                || 'c_l'
                || v_level);

        v_filename := v_filename || '.rman';
        p_filename := v_filename;                              -- Set filename

        ---------------

        v_code_filename := '# ' || v_filename;
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || ' by fn_gen_rman_backup_file'
            || CHR (10)
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       Dcox            30-May-2015     Initial build - Adapted from ESBU example
#       dcox            21-Jul-2015     modified to run for merdmp
#       dcox            19-Aug-2015     Modified to use mount for cf options
#       dcox            23-Sep-2015     Cleaned up and added catalog
#       dcox            17-Oct-2015     Added - Auto Generation of scripts
#       dcox            27-Oct-2015     Added spfile to text and copy of controlfile to backup location
#       dcox            10-Nov-2015     Added LF after "consistency"
#       dcox            08-Jan-18       rebuild to make this generic
#
#       Channel backup across 2 head bananced pools
#
# Use this script to allocate RMAN channels and run level '
            || v_level
            || ' backup.
#
';
        v_line_no := 500;                                     -- debug line no

        v_code_catalog_connect :=
               'connect catalog '
            || vgc_catalog_user_pwd
            || CHR (10)
            || CHR (10);

        v_code_echo_on := 'set echo on;' || CHR (10) || CHR (10);

        v_code_run_and_settings := 'run
{
alter system set "_backup_disk_bufcnt"=64 scope=memory sid=''*'';
alter system set "_backup_disk_bufsz"=1048576 scope=memory sid=''*'';
alter system set "_backup_file_bufcnt"=64 scope=memory sid=''*'';
alter system set "_backup_file_bufsz"=1048576 scope=memory sid=''*'';

# for consistancy' || CHR (10);
        v_line_no := 700;                                     -- debug line no

        -- Add archive log file switches
        FOR nswitch IN 1 .. vgc_archive_logfile_switches
        LOOP
            v_code_run_and_settings :=
                   v_code_run_and_settings
                || 'alter system switch logfile;'
                || CHR (10);
        END LOOP;

        v_line_no := 900;                                     -- debug line no

        -- Allocate Channels
        FOR ichannel IN 1 .. v_channels
        LOOP
            v_channel_no := LPAD (ichannel, 2, '0');    -- left padded integer
            v_line_no := 1100;                                -- debug line no

            -- set to 2 for 2 compute nodes, would need to modify code for more nodes
            IF MOD (ichannel, 2) != 0
            THEN
                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || 'allocate channel ch'
                    || v_channel_no
                    || ' device type disk connect '''
                    || vgc_rman_backup_user
                    || '/'
                    || v_sys_util_param
                    || '@'
                    || vgc_scan_address
                    || '/'
                    || LOWER (v_database)
                    || '_bkup'
                    || v_channel_no
                    || ''' format '''
                    || vgc_head1_dir_prefix
                    || '';

                IF vgc_zfs_bool
                THEN
                    v_code_allocate_channels :=
                        v_code_allocate_channels || v_channel_no;
                END IF;

                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || '/'
                    || UPPER (v_database)
                    || '/bkp_%d_%T_%U'';'
                    || CHR (10);
            ELSE
                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || 'allocate channel ch'
                    || v_channel_no
                    || ' device type disk connect '''
                    || vgc_rman_backup_user
                    || '/'
                    || v_sys_util_param
                    || '@'
                    || vgc_scan_address
                    || '/'
                    || LOWER (v_database)
                    || '_bkup'
                    || v_channel_no
                    || ''' format '''
                    || vgc_head2_dir_prefix
                    || '';

                IF vgc_zfs_bool
                THEN
                    v_code_allocate_channels :=
                        v_code_allocate_channels || v_channel_no;
                END IF;

                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || '/'
                    || UPPER (v_database)
                    || '/bkp_%d_%T_%U'';'
                    || CHR (10);
            END IF;

            v_line_no := 1300;                                -- debug line no
        END LOOP;                                 -- end allocate channel loop

        v_line_no := 2100;                                    -- debug line no
        v_code_allocate_channels :=
            v_code_allocate_channels || CHR (10) || CHR (10);

        ------------------------------------

        -- Create Tag

        --Check for Full/Incr
        IF v_level = 0
        THEN
            v_tag :=
                UPPER (v_database || '_' || v_channel_no_max || 'C_FULL_L0'); -- example MERDMR_24C_FULL_L0
        ELSE
            v_tag :=
                UPPER (
                       v_database
                    || '_'
                    || v_channel_no_max
                    || 'C_INCR_L'
                    || v_level);                 -- example MERDMR_24C_INDR_L1
        END IF;

        v_line_no := 2300;                                    -- debug line no

        v_code_backup_and_close :=
               'backup as '
            || v_compressed
            || ' backupset incremental level '
            || v_level
            || ' filesperset '
            || vgc_filesperset_all
            || ' section size '
            || vc_backup_file_size
            || 'g database tag '''
            || v_tag
            || ''' plus archivelog tag '''
            || v_tag
            || ''';'
            || CHR (10)
            || CHR (10)
            || 'delete noprompt archivelog all backed up '
            || vgc_arclog_del_policy_days
            || ' times to disk;'
            || CHR (10)
            || CHR (10);

        IF vgc_bool_skip_rman_backup_cf != TRUE
        THEN
            v_code_backup_and_close :=
                   v_code_backup_and_close
                || 'backup current controlfile tag ''controlfile01'';'
                || CHR (10);
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || CHR (10)
            || CHR (10)
            || 'ALTER DATABASE BACKUP CONTROLFILE TO '''
            || vgc_head1_dir_prefix
            || '';

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/control_'
            || v_database
            || '.bkp'' REUSE;'
            || CHR (10)
            || CHR (10)
            || 'backup spfile format        '''
            || vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/spfile_%I_%d_%T_%u'' tag ''spfile'';'
            || CHR (10)
            || CHR (10)
            || 'alter database backup controlfile to trace; '
            || CHR (10)
            || CHR (10)
            || 'alter database backup controlfile to trace as '''
            || vgc_head1_dir_prefix
            || '';

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/backup_controlfile_'
            || LOWER (v_database)
            || '_trace.trc'' reuse;'
            || CHR (10)
            || CHR (10)
            || '}'
            || CHR (10)
            || 'exit;'
            || CHR (10)
            || CHR (10);

        v_line_no := 2500;                                    -- debug line no

        v_directory := vgc_directory;

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 2700;                                    -- debug line no

        --------
        -- Create and write buffer(s) to create file
        v_buffer := v_code_filename;
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        --------

        v_buffer := v_buffer || v_code_change_block || CHR (10);

        -- check for catalog entry - no or null will be skipped
        IF SUBSTR (p_catalog, 1, 1) = 'Y'
        THEN
            v_buffer := v_buffer || v_code_catalog_connect || CHR (10);
        END IF;

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        --------
        v_buffer := v_buffer || v_code_echo_on || CHR (10);
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        --------
        v_buffer := v_buffer || v_code_run_and_settings || CHR (10);
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        --------
        v_buffer := v_buffer || v_code_allocate_channels || CHR (10);
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);

        --------
        v_buffer := v_buffer || v_code_backup_and_close || CHR (10);

        v_line_no := 2900;                                    -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 3300;                                    -- debug line no
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            UTL_FILE.fclose_all;
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_backup_file;           -- Function fn_gen_rman_backup_file

    -------------------------------------------

    FUNCTION fn_gen_rman_backup_file_stby (
        p_db_unique_name   IN     VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
        p_level            IN     INTEGER, -- Backup Level 0-Full, 1-9 -- incremental level
        p_channels         IN     INTEGER, -- Channels 1-vgc_channel_upper_limit
        p_compressed       IN     VARCHAR2, -- Y)es or N) - null will default to Yes
        p_catalog          IN     VARCHAR2 DEFAULT NULL, -- Default is N)o - Yes to add catalog entry
        p_filename         IN OUT VARCHAR2,     -- filename for monthly script
        p_error_message    IN OUT VARCHAR2       -- error message (or Success)
                                          )
        RETURN NUMBER
    IS
        /*

                    Purpose: Generate command script for rman backups
                    For Standby Databases

                    This is for a 2 head ZFS with services

                    MODIFICATION HISTORY
                    Person      Date        Comments
                    ---------   ------      -------------------------------------------
                    dcox        11/25/2015  copied from fn_gen_rman_backup_file - initial build
                    dcox        08-Jan-18   rebuild to make this generic

            */
        vc_backup_file_size   CONSTANT INTEGER := 32; -- Backup File Size in Gb (suggested 32)
        v_code_backup_and_close        VARCHAR2 (32767); -- backup statement and close of command file
        v_tag                          VARCHAR2 (100);           -- Backup Tag
        v_level                        INTEGER;                -- Backup Level
        v_channels                     INTEGER;          -- number of channels
        v_channel_no                   VARCHAR2 (4); -- actual left padded channel number ( for Looping - incremented)
        v_channel_no_max               VARCHAR2 (4); -- actual left padded channel number - static for output
        v_code_filename                VARCHAR2 (32767); -- name to be placed into code for the filename
        v_code_change_block            VARCHAR2 (32767);  -- code change block
        v_code_catalog_connect         VARCHAR2 (32767); -- code for catalog connect string
        v_code_echo_on                 VARCHAR2 (32767); -- code for echo statement
        v_code_run_and_settings        VARCHAR2 (32767); -- code for database settings to optimize rman

        v_code_allocate_channels       VARCHAR2 (32767); -- code to be used to allocate channels
        v_sys_pwd                      VARCHAR2 (100); -- password for SYS to be used in code creation
        v_sqlcode                      NUMBER;                   -- error code

        v_database                     VARCHAR2 (20); -- uppercase database name
        v_directory                    VARCHAR2 (200); -- directory to write rman file
        v_filename                     VARCHAR2 (2000); -- physical filename where code will be written
        v_file_handle                  UTL_FILE.file_type;      -- file handle
        v_buffer                       VARCHAR2 (32767); -- Write buffer for files
        v_sys_util_param               VARCHAR2 (200); -- sys utility parameter
        v_line_no                      INTEGER := 0;          -- debug line no
        v_compressed                   VARCHAR2 (200); -- used when p_compressed is null or 'Y'
    ------------------------------------------------------------------------------------------

    BEGIN
        v_line_no := 100;                                     -- debug line no

        -------------------------
        -- get fn_get_sys_utility
        BEGIN
            v_sys_util_param := fn_get_sys_utility;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (-20001,
                                         'sys_utility file not found');
        END;

        --------------------------
        -- Validate level
        IF p_level BETWEEN 0 AND 9
        THEN
            v_level := p_level;
        ELSE
            raise_application_error (-20001, 'Level is not between 0 and 9');
        END IF;

        -- Validate channels
        IF p_channels BETWEEN 1 AND vgc_channel_upper_limit
        THEN
            v_channels := p_channels;
            v_channel_no_max := LPAD (v_channels, 2, '0'); -- left padded integer
        ELSE
            raise_application_error (
                -20002,
                   'Channels is not between 1 and '
                || vgc_channel_upper_limit
                || '.');
        END IF;

        v_line_no := 150;                                     -- debug line no

        -- Check for database name
        IF p_db_unique_name IS NOT NULL
        THEN
            v_database := UPPER (p_db_unique_name);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        -- Check for compression
        IF SUBSTR (p_compressed, 1, 1) = 'Y' OR p_compressed IS NULL
        THEN
            v_compressed := ' compressed ';
        END IF;

        v_line_no := 300;                                     -- debug line no
        ----------------
        -- Compose Filename
        v_filename :=
            LOWER (
                   'backup_'
                || v_database
                || '_'
                || v_channel_no_max
                || 'c_ldr'
                || v_level);

        v_filename := v_filename || '.rman';
        p_filename := v_filename;                              -- Set filename

        ---------------

        v_code_filename := '# ' || v_filename;
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       Dcox            30-May-2015     Initial build - copied from fn_gen_rman_backup_file"
#       dcox            08-Jan-18        rebuild to make this generic
#
#       Channel backup across 2 head bananced pools
#
# Use this script to allocate RMAN channels and run level '
            || v_level
            || ' backup.
#
';
        v_line_no := 500;                                     -- debug line no

        v_code_echo_on := 'set echo on;' || CHR (10) || CHR (10);
        v_code_catalog_connect :=
               'connect catalog '
            || vgc_catalog_user_pwd
            || CHR (10)
            || CHR (10);

        v_code_run_and_settings := 'run
{
alter system set "_backup_disk_bufcnt"=64 scope=memory sid=''*'';
alter system set "_backup_disk_bufsz"=1048576 scope=memory sid=''*'';
alter system set "_backup_file_bufcnt"=64 scope=memory sid=''*'';
alter system set "_backup_file_bufsz"=1048576 scope=memory sid=''*'';

# for consistancy' || CHR (10);
        v_line_no := 700;                                     -- debug line no

        -- Allocate Channels
        FOR ichannel IN 1 .. v_channels
        LOOP
            v_channel_no := LPAD (ichannel, 2, '0');    -- left padded integer
            v_line_no := 1100;                                -- debug line no

            -- set to 2 for 2 compute nodes, would need to modify code for more nodes
            IF MOD (ichannel, 2) != 0
            THEN
                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || 'allocate channel ch'
                    || v_channel_no
                    || ' device type disk '
                    || ' format '''
                    || vgc_head1_dir_prefix
                    || '';

                IF vgc_zfs_bool
                THEN
                    v_code_allocate_channels :=
                        v_code_allocate_channels || v_channel_no;
                END IF;

                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || '/'
                    || UPPER (v_database)
                    || '/bkp_%d_%T_%U'';'
                    || CHR (10);
            ELSE
                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || 'allocate channel ch'
                    || v_channel_no
                    || ' device type disk format '''
                    || vgc_head2_dir_prefix
                    || '';

                IF vgc_zfs_bool
                THEN
                    v_code_allocate_channels :=
                        v_code_allocate_channels || v_channel_no;
                END IF;

                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || '/'
                    || UPPER (v_database)
                    || '/bkp_%d_%T_%U'';'
                    || CHR (10);
            END IF;

            v_line_no := 1300;                                -- debug line no
        END LOOP;                                 -- end allocate channel loop

        v_line_no := 2100;                                    -- debug line no
        v_code_allocate_channels :=
            v_code_allocate_channels || CHR (10) || CHR (10);

        ------------------------------------

        -- Create Tag

        --Check for Full/Incr
        IF v_level = 0
        THEN
            v_tag :=
                UPPER (v_database || '_' || v_channel_no_max || 'C_FULL_L0'); -- example MERDMR_24C_FULL_L0
        ELSE
            v_tag :=
                UPPER (
                       v_database
                    || '_'
                    || v_channel_no_max
                    || 'C_INCR_L'
                    || v_level);                 -- example MERDMR_24C_INDR_L1
        END IF;

        v_line_no := 2300;                                    -- debug line no

        -- Check for monthly

        v_code_backup_and_close :=
               'backup as '
            || v_compressed
            || ' backupset incremental level '
            || v_level
            || ' filesperset '
            || vgc_filesperset_all
            || ' section size '
            || vc_backup_file_size
            || 'g database tag '''
            || v_tag
            || ''' plus archivelog tag '''
            || v_tag
            || ''';'
            || CHR (10)
            || CHR (10);

        IF vgc_bool_skip_rman_backup_cf != TRUE
        THEN
            v_code_backup_and_close :=
                   v_code_backup_and_close
                || 'backup current controlfile tag ''controlfile01'';'
                || CHR (10);
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || CHR (10)
            || CHR (10)
            || 'ALTER DATABASE BACKUP CONTROLFILE TO '''
            || vgc_head1_dir_prefix
            || '';

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/control_'
            || v_database
            || '.bkp'' REUSE;'
            || CHR (10)
            || CHR (10)
            || 'backup spfile format        '''
            || vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/spfile_%I_%d_%T_%u'' tag ''spfile'';'
            || CHR (10)
            || CHR (10)
            || 'alter database backup controlfile to trace; '
            || CHR (10)
            || CHR (10)
            || 'alter database backup controlfile to trace as '''
            || vgc_head1_dir_prefix
            || '';

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/backup_controlfile_'
            || LOWER (v_database)
            || '_trace.trc'' reuse;'
            || CHR (10)
            || CHR (10)
            || '}'
            || CHR (10)
            || 'exit;'
            || CHR (10)
            || CHR (10);

        v_line_no := 2500;                                    -- debug line no

        -- add log if monthly file

        v_directory := vgc_directory;

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 2700;                                    -- debug line no
        -- Create and write buffer(s) to create file
        v_buffer := v_code_filename;
        v_buffer := v_buffer || v_code_change_block || CHR (10);

        -- check for catalog entry
        IF p_catalog IS NULL OR SUBSTR (p_catalog, 1, 1) = 'Y'
        THEN
            v_buffer := v_buffer || v_code_catalog_connect || CHR (10);
        END IF;

        v_buffer := v_buffer || v_code_echo_on || CHR (10);
        v_buffer := v_buffer || v_code_run_and_settings || CHR (10);
        v_buffer := v_buffer || v_code_allocate_channels || CHR (10);
        v_buffer := v_buffer || v_code_backup_and_close || CHR (10);
        v_line_no := 2900;                                    -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 3300;                                    -- debug line no
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            UTL_FILE.fclose_all;
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_backup_file_stby; -- Function fn_gen_rman_backup_file_stby

    -------------------------------------------

    -------------------------------------------
    FUNCTION fn_get_dbun
        RETURN VARCHAR2
    IS
        /*
            Purpose: Get's  the DB_UNIQUE_NAME for the database

            MODIFICATION HISTORY
            Person      Date        Comments
            ---------   ------      -------------------------------------------
            dcox        11/24/2015    Initial Build
            dcox        08-Jan-18   rebuild to make this generic
        */
        v_sid   VARCHAR2 (1000);                       -- sid for the database
    BEGIN
        SELECT db_unique_name INTO v_sid FROM v$database;

        RETURN v_sid;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END fn_get_dbun;                                   -- Function fn_get_dbun

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

    ----------------------------------------
    FUNCTION fn_get_instance_count
        RETURN NUMBER
    IS
        /*
            Purpose: Get's the number of instances available

            Note this count is for this database where this process resides
            It will be used for all remote databases calling this procedure.

            The assumption is that they are not able to contain this procedure and execute it.

            For example, standby databases.

            MODIFICATION HISTORY
            Person      Date        Comments
            ---------   ------      -------------------------------------------
            dcox        11/1/2015   Initial Build
            dcox        11/24/2015  Added notes on usage (comments only)
            dcox        08-Jan-18   rebuild to make this generic
        */
        v_instance_count   INTEGER;                          -- instance count
    BEGIN
        SELECT COUNT (*) instance_count INTO v_instance_count FROM v$instance;

        RETURN v_instance_count;
    EXCEPTION
        WHEN OTHERS
        THEN
            RETURN NULL;
    END fn_get_instance_count;               -- Function fn_get_instance_count

    ------------------------------------------

    FUNCTION fn_gen_rman_maint_file (
        p_db_unique_name   IN     VARCHAR2 DEFAULT NULL,     -- DB UNIQUE NAME
        p_catalog          IN     VARCHAR2 DEFAULT NULL, -- Default is N)o,  Y)es to add catalog entry
        p_filename         IN OUT VARCHAR2, -- filename for maintenance script
        p_error_message    IN OUT VARCHAR2       -- error message (or Success)
                                          )
        RETURN NUMBER
    IS
        /*

                    Purpose: Generate command script for rman maintenance

                    This is for a 2 head ZFS with services

                    MODIFICATION HISTORY
                    Person      Date        Comments
                    ---------   ------      -------------------------------------------
                    dcox        10/15/2015    Initial Build
                    dcox        11/25/2015  Added parameter and clause to exclude catalog
                    dcox        08-Jan-18   rebuild to make this generic

            */
        v_tag                    VARCHAR2 (100);                 -- Backup Tag
        vc_catalog_user_pwd      VARCHAR2 (100) := vgc_catalog_user_pwd;
        v_code_filename          VARCHAR2 (32767); -- name to be placed into code for the filename
        v_code_change_block      VARCHAR2 (32767);        -- code change block
        v_code_catalog_connect   VARCHAR2 (32767); -- code for catalog connect string
        v_code_echo_on           VARCHAR2 (32767);  -- code for echo statement
        v_code_maint_and_close   VARCHAR2 (32767); -- backup statement and close of command file
        v_sqlcode                NUMBER;                         -- error code

        v_database               VARCHAR2 (20);     -- uppercase database name

        v_filename               VARCHAR2 (2000); -- physical filename where code will be written
        v_file_handle            UTL_FILE.file_type;            -- file handle
        v_buffer                 VARCHAR2 (32767);   -- Write buffer for files
        v_line_no                INTEGER := 0;                -- debug line no
    ------------------------------------------------------------------------------------------

    BEGIN
        v_line_no := 100;                                     -- debug line no

        -- Check for database name
        IF p_db_unique_name IS NOT NULL
        THEN
            v_database := UPPER (p_db_unique_name);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        v_line_no := 300;                                     -- debug line no
        ----------------
        -- Compose Filename
        v_filename := LOWER ('backup_' || v_database || '_lm.rman');
        p_filename := v_filename;                              -- Set filename

        ---------------

        v_code_filename := '# ' || v_filename;
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       Dcox            30-May-2015     Initial build
#       dcox            23-Sep-2015     Cleaned up and added catalog
#       dcox            19-Oct-2015     Added - Auto Generation of scripts
#       dcox            08-Jan-18       rebuild to make this generic
#
#       Channel backup across 2 head bananced pools
#
# Use this script to run RMAN maintenance commands';
        v_line_no := 500;                                     -- debug line no

        v_code_catalog_connect :=
            'connect catalog ' || vc_catalog_user_pwd || CHR (10) || CHR (10);

        v_code_echo_on := 'set echo on;' || CHR (10) || CHR (10);

        v_line_no := 700;                                     -- debug line no

        ------------------------------------

        v_line_no := 2300;                                    -- debug line no
        v_code_maint_and_close :=
               'run
{
# Std Parameters
CONFIGURE DEVICE TYPE DISK PARALLELISM '
            || FLOOR (vgc_channel_upper_limit / fn_get_instance_count)
            || ' BACKUP TYPE TO BACKUPSET;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE RMAN OUTPUT TO KEEP FOR 90 DAYS;
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF '
            || vgc_base_retention_days
            || ' DAYS;
CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP '
            || vgc_arclog_del_policy_days
            || ' TIMES TO DISK;
configure snapshot controlfile name to '''
            || vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_maint_and_close := v_code_maint_and_close || '01cf/';
        ELSE
            v_code_maint_and_close := v_code_maint_and_close || '/';
        END IF;

        v_code_maint_and_close :=
               v_code_maint_and_close
            || UPPER (v_database)
            || '/snapcf_'
            || LOWER (v_database)
            || '.cf'';

# Check and clean up
crosscheck backup;
crosscheck archivelog all;
delete noprompt expired backup;
delete force noprompt obsolete;
delete noprompt backup completed before ''SYSDATE-'
            || vgc_cleanup_after_days
            || '''; # vgc_cleanup_after_days - cleanup after this number of days
delete noprompt archivelog all completed before ''SYSDATE-'
            || vgc_cleanup_after_days
            || ''';    # vgc_cleanup_after_days - cleanup after this number of days
report unrecoverable;
report need backup;

}
list backup;
list archivelog all;

exit 0;
'
            || CHR (10)
            || CHR (10);
        v_line_no := 2500;                                    -- debug line no

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 2700;                                    -- debug line no
        -- Create and write buffer(s) to create file
        v_buffer := v_code_filename || CHR (10);
        v_buffer := v_buffer || v_code_change_block || CHR (10);

        IF SUBSTR (p_catalog, 1, 1) = 'Y'
        THEN
            v_buffer := v_buffer || v_code_catalog_connect || CHR (10);
        END IF;

        v_buffer := v_buffer || v_code_echo_on || CHR (10);
        v_buffer := v_buffer || v_code_maint_and_close || CHR (10);
        v_line_no := 2900;                                    -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 3300;                                    -- debug line no
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            UTL_FILE.fclose_all;
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_maint_file;             -- Function fn_gen_rman_maint_file

    ------------------------------------------

    FUNCTION fn_gen_rman_maint_file_stby (
        p_db_unique_name   IN     VARCHAR2 DEFAULT NULL,     -- DB UNIQUE NAME
        p_catalog          IN     VARCHAR2 DEFAULT NULL, -- Default is N)o,  Y)es to add catalog entry
        p_filename         IN OUT VARCHAR2, -- filename for maintenance script
        p_error_message    IN OUT VARCHAR2       -- error message (or Success)
                                          )
        RETURN NUMBER
    IS
        /*

                    Purpose: Generate command script for rman maintenance

                    This is for a 2 head ZFS with services

                    MODIFICATION HISTORY
                    Person      Date        Comments
                    ---------   ------      -------------------------------------------
                    dcox        10/15/2015    Initial Build
                    dcox        11/25/2015  Added parameter and clause to exclude catalog
                    dcox        08-Jan-18   rebuild to make this generic

            */
        v_tag                    VARCHAR2 (100);                 -- Backup Tag

        v_code_filename          VARCHAR2 (32767); -- name to be placed into code for the filename
        v_code_change_block      VARCHAR2 (32767);        -- code change block
        v_code_catalog_connect   VARCHAR2 (32767); -- code for catalog connect string
        v_code_echo_on           VARCHAR2 (32767);  -- code for echo statement
        v_code_maint_and_close   VARCHAR2 (32767); -- backup statement and close of command file
        v_sqlcode                NUMBER;                         -- error code

        v_database               VARCHAR2 (20);     -- uppercase database name

        v_filename               VARCHAR2 (2000); -- physical filename where code will be written
        v_file_handle            UTL_FILE.file_type;            -- file handle
        v_buffer                 VARCHAR2 (32767);   -- Write buffer for files
        v_line_no                INTEGER := 0;                -- debug line no
    ------------------------------------------------------------------------------------------

    BEGIN
        v_line_no := 100;                                     -- debug line no

        -- Check for database name
        IF p_db_unique_name IS NOT NULL
        THEN
            v_database := UPPER (p_db_unique_name);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        v_line_no := 300;                                     -- debug line no
        ----------------
        -- Compose Filename
        v_filename := LOWER ('backup_' || v_database || '_lm.rman');
        p_filename := v_filename;                              -- Set filename

        ---------------

        v_code_filename := '# ' || v_filename;
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       Dcox            30-May-2015     Initial build
#       dcox            23-Sep-2015     Cleaned up and added catalog
#       dcox            19-Oct-2015     Added - Auto Generation of scripts
#       dcox            08-Jan-18       rebuild to make this generic
#
#       Channel backup across 2 head bananced pools
#
# Use this script to run RMAN maintenance commands';
        v_line_no := 500;                                     -- debug line no

        v_code_catalog_connect :=
               'connect catalog '
            || vgc_catalog_user_pwd
            || CHR (10)
            || CHR (10);

        v_code_echo_on := 'set echo on;' || CHR (10) || CHR (10);

        v_line_no := 700;                                     -- debug line no

        ------------------------------------

        v_line_no := 2300;                                    -- debug line no
        v_code_maint_and_close :=
               'run
{
# Std Parameters
CONFIGURE DEVICE TYPE DISK PARALLELISM '
            || FLOOR (vgc_channel_upper_limit / fn_get_instance_count)
            || ' BACKUP TYPE TO BACKUPSET;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE RMAN OUTPUT TO KEEP FOR 90 DAYS;
CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP '
            || vgc_arclog_del_policy_days
            || ' TIMES TO DISK;
configure snapshot controlfile name to '''
            || vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_maint_and_close := v_code_maint_and_close || '01cf/';
        ELSE
            v_code_maint_and_close := v_code_maint_and_close || '/';
        END IF;

        v_code_maint_and_close :=
               v_code_maint_and_close
            || UPPER (v_database)
            || '/snapcf_'
            || LOWER (v_database)
            || '.cf'';

# Check and clean up
crosscheck backup;
crosscheck archivelog all;
delete noprompt expired backup;
delete force noprompt obsolete;
delete noprompt backup completed before ''SYSDATE-'
            || vgc_cleanup_after_days
            || '''; # vgc_cleanup_after_days - cleanup after this number of days
delete noprompt archivelog all completed before ''SYSDATE-'
            || vgc_cleanup_after_days
            || ''';    # vgc_cleanup_after_days - cleanup after this number of days
report unrecoverable;
report need backup;

}
list backup;
list archivelog all;

exit 0;
'
            || CHR (10)
            || CHR (10);
        v_line_no := 2500;                                    -- debug line no

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 2700;                                    -- debug line no
        -- Create and write buffer(s) to create file
        v_buffer := v_code_filename || CHR (10);
        v_buffer := v_buffer || v_code_change_block || CHR (10);

        IF SUBSTR (p_catalog, 1, 1) = 'Y'
        THEN
            v_buffer := v_buffer || v_code_catalog_connect || CHR (10);
        END IF;

        v_buffer := v_buffer || v_code_echo_on || CHR (10);
        v_buffer := v_buffer || v_code_maint_and_close || CHR (10);
        v_line_no := 2900;                                    -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 3300;                                    -- debug line no
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            UTL_FILE.fclose_all;
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_maint_file_stby;   -- Function fn_gen_rman_maint_file_stby

    ------------------------------------------------------------
    PROCEDURE p_ksh_gen_base_directories (p_notes            IN VARCHAR2 DEFAULT NULL, -- writes notes to header
                                          p_db_unique_name   IN VARCHAR2 -- Database UNIQUE NAME
                                                                        )
    IS
        /*

        Purpose: Generate ksh script with base directories for current database



        MODIFICATION HISTORY
        Person      Date            Comments
        ---------   ------          -------------------------------------------
        dcox        10/19/2015      Initial Build
        dcox        24-Nov-2015     Added monthly and -p parameter and executes with one commmand
                                    Creating both the /<DBUNQ> and /<DBUNQ>/monthly
                                    (added since Data Domain will not follow links)
                                    Also added debug "ON"
        dcox        05-Jan-2018     Removed Monthly script creation - change to generic

        */

        v_database        VARCHAR2 (100);                          -- database
        v_return          NUMBER;
        v_filename_ksh    VARCHAR2 (500);         -- filename -- subscript ksh

        v_error_message   VARCHAR2 (32767);          -- error message returned
        v_channel_no      VARCHAR2 (5);                     -- channel numbers
        v_buffer          VARCHAR2 (32767);       -- buffer to write to script
        v_date            DATE := TRUNC (SYSDATE); -- date used for operations in this proc
        v_file_handle     UTL_FILE.file_type;                   -- file handle
    BEGIN
        -- get database name
        IF p_db_unique_name IS NULL
        THEN
            v_database := fn_get_dbun;
        ELSE
            v_database := p_db_unique_name;
        END IF;

        -- Create filename
        v_filename_ksh := 'rman_base_script_setup_' || v_database || '.ksh';

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename_ksh,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- Write File Header
        v_buffer :=
               v_buffer
            || '#!/bin/ksh'
            || CHR (10)
            || '# Filename: '
            || v_filename_ksh
            || CHR (10)
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#       Purpose: Create file system for a new database added to rman backups'
            || '#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
# Notes: '
            || p_notes
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       Dcox            19-Oct-2015     Initial build  - Auto Generation of scripts
#       dcox            24-Nov-2015     Added monthly and -p parameter and executes with one commmand
#                                       Creating both the /<DBUNQ> and /<DBUNQ>/monthly ( added since Data Domain will not follow links)
#       dcox            05-Jan-2018     Removed Monthly directories - move code to generic version
#       dcox            08-Jan-18        rebuild to make this generic
# '
            || CHR (10)
            || 'set -x # debug on'
            || CHR (10)
            || CHR (10);

        -- create new directories
        FOR ichannel IN 1 .. vgc_channel_upper_limit
        LOOP               -- Change all directories even if they are not used
            v_channel_no := LPAD (ichannel, 2, '0');    -- left padded integer

            IF MOD (ichannel, 2) = 1
            THEN                                            -- Odd directories
                v_buffer :=
                       v_buffer
                    || 'mkdir -p '
                    || vgc_head1_dir_prefix
                    || v_channel_no
                    || '/'
                    || UPPER (v_database)
                    || '/'
                    || CHR (10);
            ELSE
                v_buffer :=
                       v_buffer
                    || 'mkdir -p '
                    || vgc_head2_dir_prefix
                    || v_channel_no
                    || '/'
                    || UPPER (v_database)
                    || '/'
                    || CHR (10);
            END IF;                                        -- end odd and even
        END LOOP;                                  -- loop to make directories

        -- Write Exit code 0
        v_buffer :=
               v_buffer
            || CHR (10)
            || '# End of Script'
            || CHR (10)
            || CHR (10)                                        /*|| 'exit 0'*/
            || CHR (10)
            || CHR (10);
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);

        UTL_FILE.fclose (file => v_file_handle);
    EXCEPTION
        WHEN OTHERS
        THEN
            UTL_FILE.fclose_all;
            RAISE;
    END p_ksh_gen_base_directories;    -- Procedure p_ksh_gen_base_directories

    -------------------------------------------

    PROCEDURE p_create_standard_channels (
        p_db_unique_name   IN VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
        p_catalog          IN VARCHAR2 DEFAULT NULL, -- Default is N)o - Y)es to add catalog
        p_channels_max     IN VARCHAR2 DEFAULT NULL -- Desired maximum number of channels needed
                                                   )
    IS
        /*
                   Purpose: Get's  the SID for the database

                   MODIFICATION HISTORY
                   Person      Date         Comments
                   ---------   ------       -------------------------------------------
                   dcox        11/1/2015    Initial Build
                   dcox        11/24/2015   Added explicit code to set default database here before other procedures are called
                   dcox        11/25/2015   Added catalog exclusion when creating files for standby's
                   dcox        12/11/2015   Removed the standby parameter changed to catalog default - will defult to 'N'
                   dcox        01/08/2018   Added code to set max channels - set incremental values to 2 (can change on constant)
                   dcox        08-Jan-18    rebuild to make this generic
               */
        v_return                         NUMBER;
        v_filename                       VARCHAR2 (32000);
        v_error_message                  VARCHAR2 (32000);
        v_channel                        INTEGER;           --  channel number
        v_database                       VARCHAR2 (30);       -- database name
        v_catalog                        VARCHAR2 (2); -- When 'N' then no catalog generated, otherwise left null and catalog entry is created
        v_channel_step_max               INTEGER; -- stepping to max size (derived from p_max_channels and incremental size
        vc_channel_increments   CONSTANT INTEGER := 2;            -- step size
    BEGIN
        -- check for standby
        IF SUBSTR (p_catalog, 1, 1) = 'Y'
        THEN
            v_catalog := 'Y';
        ELSE
            v_catalog := 'N';
        END IF;

        -- get database name
        IF p_db_unique_name IS NULL
        THEN
            v_database := fn_get_dbun;
        ELSE
            v_database := p_db_unique_name;
        END IF;

        -- calculate channel variables
        v_channel_step_max := p_channels_max / vc_channel_increments;       --

        FOR ichannels IN 1 .. v_channel_step_max
        LOOP
            v_channel := ichannels * vc_channel_increments;
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_channel=' || TO_CHAR (v_channel), 1, 255));

            FOR ilevel IN 0 .. 1
            LOOP
                v_filename := NULL;
                v_error_message := NULL;

                -- Now Call the stored program
                v_return :=
                    pkg_rman_script_gen_prd.fn_gen_rman_backup_file (
                        p_database        => v_database,
                        p_level           => ilevel,
                        p_channels        => v_channel,
                        p_compressed      => vgc_compressed_default,
                        p_catalog         => v_catalog,
                        p_filename        => v_filename,
                        p_error_message   => v_error_message);

                IF v_return < 0
                THEN
                    raise_application_error (
                        -20001,
                        v_return || ' ' || v_error_message);
                END IF;
            END LOOP;
        -- Levels
        END LOOP;                                                  -- channels

        -- Gen Maintenance File
        v_return :=
            pkg_rman_script_gen_prd.fn_gen_rman_maint_file (
                p_db_unique_name   => v_database,
                p_catalog          => v_catalog, -- Default is Y)es - N)o to stop adding catalog entry
                p_filename         => v_filename,
                p_error_message    => v_error_message);

        -- Generate the service creation file
        v_return :=
            fn_gen_file_to_create_bkupsvc (
                p_db_unique_name       => v_database,  -- Database UNIQUE NAME
                p_db_name              => v_database,      -- Database DB_NAME
                p_compute_nodes        => vgc_compute_nodes, -- number of compute nodes
                p_number_of_services   => p_channels_max, -- Number of services to create
                p_error_message        => v_error_message     -- error message
                                                         );
        -- Generate the service Stop / Start file
        v_return :=
            fn_gen_file_to_ss_bkupsvc (
                p_db_unique_name       => v_database,  -- Database UNIQUE NAME
                p_db_name              => v_database,      -- Database DB_NAME
                p_compute_nodes        => vgc_compute_nodes, -- number of compute nodes
                p_number_of_services   => p_channels_max, -- Number of services to create
                p_error_message        => v_error_message     -- error message
                                                         );

        -- Generate recovery file
        v_return :=
            pkg_rman_script_gen_prd.fn_gen_rcvr_local_with_s_c (
                p_dbid                => '0', -- DB ID from original DB (if it is to be set the same (null if not setting this)
                p_db_name             => v_database, -- Database NAME - Matching /zfssa/.../backupxx/<DB_NAME> - you can change later if needed or modify scripts
                p_db_unique_name      => v_database,   -- Database UNIQUE NAME
                p_oracle_base         => vgc_oracle_base,       -- ORACLE_BASE
                p_oracle_home         => vgc_oracle_home,       -- ORACLE_HOME
                p_db_instance_name    => v_database || '1', -- instance name and number to be started on initial machine
                p_compute_nodes       => vgc_compute_nodes, -- number of compute nodes
                p_previous_asm_data   => vgc_default_asm_data, -- previous DATA ASM disk group (like +DATA_DM) - Auxiliary
                p_current_asm_data    => vgc_default_asm_data, -- current  DATA ASM disk group (like +DATA_WH) - Target
                p_previous_asm_reco   => vgc_default_asm_reco, -- previous RECO ASM disk group (like +RECO_DM) - Auxiliary
                p_current_asm_reco    => vgc_default_asm_reco, -- current  RECO ASM disk group (like +RECO_WH) - Target
                p_machine_name_1      => 'examiddbadm01', -- machine name (adm name for db compute node)
                p_machine_name_2      => 'examiddbadm01', -- machine name (adm name for db compute node)
                p_machine_name_3      => NULL, -- machine name (adm name for db compute node)
                p_machine_name_4      => NULL, -- machine name (adm name for db compute node)
                p_machine_name_5      => NULL, -- machine name (adm name for db compute node)
                p_machine_name_6      => NULL, -- machine name (adm name for db compute node)
                p_machine_name_7      => NULL, -- machine name (adm name for db compute node)
                p_machine_name_8      => NULL, -- machine name (adm name for db compute node)
                p_error_message       => v_error_message -- If there is an error message (return code less than zero - then return message
                                                        );
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END p_create_standard_channels;    -- Procedure p_create_standard_channels

    -------------------------------------------

    PROCEDURE p_create_standby_channels (
        p_db_unique_name   IN VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
        p_db_name          IN VARCHAR2 DEFAULT NULL,                -- DB NAME
        p_channels_max     IN VARCHAR2 DEFAULT NULL -- Desired maximum number of channels needed
                                                   )
    IS
        /*
                   Purpose: Get's  the SID for the database

                   MODIFICATION HISTORY
                   Person      Date         Comments
                   ---------   ------       -------------------------------------------
                   dcox        11/25/2015   Initial Build - copied from p_create_stanby_channels
                   dcox        01/08/2017   Modified for max channel size incremental sizes set to 2
                   dcox        08-Jan-18   rebuild to make this generic
               */
        v_return                         NUMBER;
        v_filename                       VARCHAR2 (32000);
        v_error_message                  VARCHAR2 (32000);
        v_channel                        INTEGER;           --  channel number
        v_db_name                        VARCHAR2 (30); -- database name - db_unique_name
        v_db_unique_name                 VARCHAR2 (30); -- database name - db_name
        v_catalog                        VARCHAR2 (2); -- When 'N' then no catalog generated, otherwise left null and catalog entry is created
        v_channel_step_max               INTEGER; -- stepping to max size (derived from p_max_channels and incremental size
        vc_channel_increments   CONSTANT INTEGER := 2;            -- step size
    BEGIN
        -- check for standby
        v_catalog := 'Y'; -- Set to yes by default for standby database (this is an option on standard channels)

        -- get database name - db unique name
        IF p_db_unique_name IS NULL
        THEN
            v_db_unique_name := fn_get_dbun;
        ELSE
            v_db_unique_name := p_db_unique_name;
        END IF;

        DBMS_OUTPUT.put_line (
            SUBSTR (
                'Value of v_db_unique_name=' || TO_CHAR (v_db_unique_name),
                1,
                255));

        -- get db_name
        IF p_db_name IS NULL
        THEN
            v_db_name := fn_get_dbun;
        ELSE
            v_db_name := p_db_name;
        END IF;

        -- calculate channel variables
        v_channel_step_max := p_channels_max / vc_channel_increments;       --

        FOR ichannels IN 1 .. v_channel_step_max
        LOOP
            v_channel := ichannels * vc_channel_increments;

            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_channel=' || TO_CHAR (v_channel), 1, 255));

            FOR ilevel IN 0 .. 1
            LOOP
                v_filename := NULL;
                v_error_message := NULL;

                -- Now Call the stored program
                v_return :=
                    pkg_rman_script_gen_prd.fn_gen_rman_backup_file_stby (
                        p_db_unique_name   => v_db_unique_name, -- db unique name
                        p_level            => ilevel,
                        p_channels         => v_channel,
                        p_compressed       => vgc_compressed_default,
                        p_catalog          => v_catalog,
                        p_filename         => v_filename,
                        p_error_message    => v_error_message);

                IF v_return < 0
                THEN
                    raise_application_error (
                        -20001,
                        v_return || ' ' || v_error_message);
                END IF;
            END LOOP;
        -- Levels
        END LOOP;                                                  -- channels

        -- Gen Maintenance File
        v_return :=
            pkg_rman_script_gen_prd.fn_gen_rman_maint_file_stby (
                p_db_unique_name   => v_db_unique_name,
                p_catalog          => v_catalog, -- Default is Y)es - N)o to stop adding catalog entry
                p_filename         => v_filename,
                p_error_message    => v_error_message);
    /*    -- Generate the service creation file - only for active Data Guard
        v_return :=
            fn_gen_file_to_create_bkupsvc (
                p_db_unique_name       => v_db_unique_name, -- Database UNIQUE NAME
                p_db_name              => v_db_name,       -- Database DB_NAME
                p_compute_nodes        => vgc_compute_nodes, -- number of compute nodes
                p_number_of_services   => p_channels_max, -- Number of services to create
                p_error_message        => v_error_message     -- error message
                                                         );
      -- Generate the service Stop / Start file
      v_return :=
          fn_gen_file_to_ss_bkupsvc (
              p_db_unique_name       => v_db_unique_name, -- Database UNIQUE NAME
              p_db_name              => v_db_name,       -- Database DB_NAME
              p_compute_nodes        => vgc_compute_nodes, -- number of compute nodes
              p_number_of_services   => p_channels_max, -- Number of services to create
              p_error_message        => v_error_message     -- error message
                                                       );*/
    EXCEPTION
        WHEN OTHERS
        THEN
            RAISE;
    END p_create_standby_channels;      -- Procedure p_create_standby_channels

    -------------------------------------------
    FUNCTION fn_gen_rman_backup_ext (
        p_database           IN     VARCHAR2 DEFAULT NULL, -- DB UNIQUE NAME (will create for local database if no database is specified)
        p_level              IN     INTEGER, -- Backup Level 0-Full, 1-9 -- incremental level
        p_channels           IN     INTEGER, -- Channels 1-vgc_channel_upper_limit
        p_compressed         IN     VARCHAR2, -- Y)es or N)o - null will default to No
        p_head1_dir_prefix   IN     VARCHAR2,                -- path to head 1
        p_head2_dir_prefix   IN     VARCHAR2,                -- path to head 2
        p_date               IN     DATE DEFAULT NULL, -- Date provided for Monthly backups only - will force to a full
        p_catalog            IN     VARCHAR2 DEFAULT NULL, -- Default is Y)es - N)o to stop adding catalog entry
        p_filename           IN OUT VARCHAR2,   -- filename for monthly script
        p_error_message      IN OUT VARCHAR2     -- error message (or Success)
                                            )
        RETURN NUMBER
    IS
        /*

                    Purpose: Generate command script for rman backups
                    -- Uses specified parameters for different backup target directory paths



                    This is for a 2 head ZFS with services

                    MODIFICATION HISTORY
                    Person      Date        Comments
                    ---------   ------      -------------------------------------------
                    dcox        10/15/2015    Initial Build
                    dcox        10/25/2015  Moved monthly command files to .../rman/log
                    dcox        10/29/2015  Added Reuse and sp/control file backups
                    dcox        11/7/2015   changed spfile to correct restore to backup
                    dcox        11/9/2015   Added external to filename
                    dcox        11/10/2015  Added LF after "consistency"
                    dcox        11/13/2015  Added backup controlfile to trace
                    dcox        11/15/2015  Corrected to use p_head1_dir_prefix, replaced vgc_head1_dir_prefix
                    dcox        11/25/2015  Added parameter and clause to exclude catalog
                    dcox        08-Jan-18   rebuild to make this generic

            */

        vc_backup_file_size   CONSTANT INTEGER := 32; -- Backup File Size in Gb (suggested 32)
        v_code_backup_and_close        VARCHAR2 (32767); -- backup statement and close of command file
        v_tag                          VARCHAR2 (100);           -- Backup Tag
        vc_catalog_user_pwd            VARCHAR2 (100)
                                           := 'exarman/b6a9dRwR@rcat2p';
        v_level                        INTEGER;                -- Backup Level
        v_channels                     INTEGER;          -- number of channels
        v_channel_no                   VARCHAR2 (4); -- actual left padded channel number ( for Looping - incremented)
        v_channel_no_max               VARCHAR2 (4); -- actual left padded channel number - static for output
        v_code_filename                VARCHAR2 (32767); -- name to be placed into code for the filename
        v_code_change_block            VARCHAR2 (32767);  -- code change block
        v_code_catalog_connect         VARCHAR2 (32767); -- code for catalog connect string
        v_code_echo_on                 VARCHAR2 (32767); -- code for echo statement
        v_code_run_and_settings        VARCHAR2 (32767); -- code for database settings to optimize rman

        v_code_allocate_channels       VARCHAR2 (32767); -- code to be used to allocate channels
        v_sys_pwd                      VARCHAR2 (100); -- password for SYS to be used in code creation
        v_sqlcode                      NUMBER;                   -- error code

        v_database                     VARCHAR2 (20); -- uppercase database name
        v_directory                    VARCHAR2 (200); -- directory to write rman file
        v_filename                     VARCHAR2 (2000); -- physical filename where code will be written
        v_file_handle                  UTL_FILE.file_type;      -- file handle
        v_buffer                       VARCHAR2 (32767); -- Write buffer for files
        v_sys_util_param               VARCHAR2 (200); -- sys utility parameter
        v_line_no                      INTEGER := 0;          -- debug line no
        v_compressed                   VARCHAR2 (200); -- used when p_compressed is null or 'Y'
    ------------------------------------------------------------------------------------------

    BEGIN
        v_line_no := 100;                                     -- debug line no

        -------------------------
        -- get fn_get_sys_utility
        BEGIN
            v_sys_util_param := fn_get_sys_utility;
        EXCEPTION
            WHEN OTHERS
            THEN
                raise_application_error (-20001,
                                         'sys_utility file not found');
        END;

        --------------------------
        -- Validate level
        IF p_level BETWEEN 0 AND 9
        THEN
            v_level := p_level;
        ELSE
            raise_application_error (-20001, 'Level is not between 0 and 9');
        END IF;

        -- Validate channels
        IF p_channels BETWEEN 1 AND vgc_channel_upper_limit
        THEN
            v_channels := p_channels;
            v_channel_no_max := LPAD (v_channels, 2, '0'); -- left padded integer
        ELSE
            raise_application_error (
                -20002,
                   'Channels is not between 1 and '
                || vgc_channel_upper_limit
                || '.');
        END IF;

        v_line_no := 150;                                     -- debug line no

        -- Check for database name
        IF p_database IS NOT NULL
        THEN
            v_database := UPPER (p_database);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        -- Check for compression
        IF SUBSTR (p_compressed, 1, 1) = 'Y' OR p_compressed IS NULL
        THEN
            v_compressed := ' compressed ';
        END IF;

        v_line_no := 300;                                     -- debug line no
        ----------------
        -- Compose Filename
        v_filename :=
            LOWER (
                   'backup_'
                || v_database
                || '_'
                || v_channel_no_max
                || 'c_l'
                || v_level
                || '_external');

        v_filename := v_filename || '.rman';
        p_filename := v_filename;                              -- Set filename

        ---------------

        v_code_filename := '# ' || v_filename;
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       Dcox            30-May-2015     Initial build - Adapted from ESBU example
#       dcox            21-Jul-2015     modified to run for merdmp
#       dcox            19-Aug-2015     Modified to use mount for cf options
#       dcox            23-Sep-2015     Cleaned up and added catalog
#       dcox            17-Oct-2015     Added - Auto Generation of scripts
#       dcox            10-Nov-2015     Added LF after "consistency"
#       dcox            25-Nov-2015     Added clause to exclude catalog if nocatalog desired
#       dcox            08-Jan-18        rebuild to make this generic
#
#       Channel backup across 2 head bananced pools
#
# Use this script to allocate RMAN channels and run level '
            || v_level
            || ' backup.
#
';
        v_line_no := 500;                                     -- debug line no

        -- check for catalog entry -- no or null is skipped
        IF SUBSTR (p_catalog, 1, 1) = 'Y'
        THEN
            v_code_catalog_connect :=
                   'connect catalog '
                || vc_catalog_user_pwd
                || CHR (10)
                || CHR (10);
        END IF;

        v_code_echo_on := 'set echo on;' || CHR (10) || CHR (10);

        v_code_run_and_settings := 'run
{
alter system set "_backup_disk_bufcnt"=64 scope=memory sid=''*'';
alter system set "_backup_disk_bufsz"=1048576 scope=memory sid=''*'';
alter system set "_backup_file_bufcnt"=64 scope=memory sid=''*'';
alter system set "_backup_file_bufsz"=1048576 scope=memory sid=''*'';

# for consistancy' || CHR (10);
        v_line_no := 700;                                     -- debug line no

        -- Add archive log file switches
        FOR nswitch IN 1 .. vgc_archive_logfile_switches
        LOOP
            v_code_run_and_settings :=
                   v_code_run_and_settings
                || 'alter system switch logfile;'
                || CHR (10);
        END LOOP;

        v_line_no := 900;                                     -- debug line no

        -- Allocate Channels
        FOR ichannel IN 1 .. v_channels
        LOOP
            v_channel_no := LPAD (ichannel, 2, '0');    -- left padded integer
            v_line_no := 1100;                                -- debug line no

            IF MOD (ichannel, 2) != 0
            THEN
                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || 'allocate channel ch'
                    || v_channel_no
                    || ' device type disk connect '''
                    || vgc_rman_backup_user
                    || '/'
                    || v_sys_util_param
                    || '@'
                    || vgc_scan_address
                    || '/'
                    || LOWER (v_database)
                    || '_bkup'
                    || v_channel_no
                    || ''' format '''
                    || p_head1_dir_prefix
                    || '';

                IF vgc_zfs_bool
                THEN
                    v_code_allocate_channels :=
                        v_code_allocate_channels || v_channel_no;
                END IF;

                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || '/'
                    || UPPER (v_database)
                    || '/bkp_%d_%T_%U'';'
                    || CHR (10);
            ELSE
                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || 'allocate channel ch'
                    || v_channel_no
                    || ' device type disk connect '''
                    || vgc_rman_backup_user
                    || '/'
                    || v_sys_util_param
                    || '@'
                    || vgc_scan_address
                    || '/'
                    || LOWER (v_database)
                    || '_bkup'
                    || v_channel_no
                    || ''' format '''
                    || p_head2_dir_prefix
                    || '';

                IF vgc_zfs_bool
                THEN
                    v_code_allocate_channels :=
                        v_code_allocate_channels || v_channel_no;
                END IF;

                v_code_allocate_channels :=
                       v_code_allocate_channels
                    || '/'
                    || UPPER (v_database)
                    || '/bkp_%d_%T_%U'';'
                    || CHR (10);
            END IF;

            v_line_no := 1300;                                -- debug line no
        END LOOP;                                 -- end allocate channel loop

        v_line_no := 2100;                                    -- debug line no
        v_code_allocate_channels :=
            v_code_allocate_channels || CHR (10) || CHR (10);

        ------------------------------------

        -- Create Tag

        --Check for Full/Incr
        IF v_level = 0
        THEN
            v_tag :=
                UPPER (v_database || '_' || v_channel_no_max || 'C_FULL_L0'); -- example MERDMR_24C_FULL_L0
        ELSE
            v_tag :=
                UPPER (
                       v_database
                    || '_'
                    || v_channel_no_max
                    || 'C_INCR_L'
                    || v_level);                 -- example MERDMR_24C_INDR_L1
        END IF;

        v_line_no := 2300;                                    -- debug line no

        v_code_backup_and_close :=
               'backup as '
            || v_compressed
            || ' backupset incremental level '
            || v_level
            || ' filesperset '
            || vgc_filesperset_all
            || ' section size '
            || vc_backup_file_size
            || 'g database tag '''
            || v_tag
            || ''' plus archivelog tag '''
            || v_tag
            || ''';'
            || CHR (10)
            || CHR (10)
            || 'delete noprompt archivelog all backed up '
            || vgc_arclog_del_policy_days
            || ' times to disk;'
            || CHR (10)
            || CHR (10);

        IF vgc_bool_skip_rman_backup_cf != TRUE
        THEN
            v_code_backup_and_close :=
                   v_code_backup_and_close
                || 'backup current controlfile tag ''controlfile01'';'
                || CHR (10);
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || 'ALTER DATABASE BACKUP CONTROLFILE TO '''
            || p_head1_dir_prefix
            || '';

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || '/'
            || UPPER (v_database)
            || '/control_'
            || v_database
            || '.bkp'' REUSE;'
            || CHR (10)
            || CHR (10)
            || 'backup spfile format        '''
            || p_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/spfile_%I_%d_%T_%u'' tag ''spfile'';'
            || CHR (10)
            || CHR (10)
            || 'alter database backup controlfile to trace; '
            || CHR (10)
            || CHR (10)
            || 'alter database backup controlfile to trace as '''
            || p_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_code_backup_and_close := v_code_backup_and_close || '01cf/'; -- Controlfile on 01
        ELSE
            v_code_backup_and_close := v_code_backup_and_close || '/';
        END IF;

        v_code_backup_and_close :=
               v_code_backup_and_close
            || UPPER (v_database)
            || '/backup_controlfile_'
            || LOWER (v_database)
            || '_trace.trc'' reuse;'
            || CHR (10)
            || CHR (10)
            || '}'
            || CHR (10)
            || 'exit;'
            || CHR (10)
            || CHR (10);

        v_line_no := 2500;                                    -- debug line no

        v_directory := vgc_directory;

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 2700;                                    -- debug line no
        -- Create and write buffer(s) to create file
        v_buffer := v_code_filename;
        v_buffer := v_buffer || v_code_change_block || CHR (10);
        v_buffer := v_buffer || v_code_catalog_connect || CHR (10);
        v_buffer := v_buffer || v_code_echo_on || CHR (10);
        v_buffer := v_buffer || v_code_run_and_settings || CHR (10);
        v_buffer := v_buffer || v_code_allocate_channels || CHR (10);
        v_buffer := v_buffer || v_code_backup_and_close || CHR (10);
        v_line_no := 2900;                                    -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        v_line_no := 3300;                                    -- debug line no
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            UTL_FILE.fclose_all;
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_backup_ext;            -- Function fn_gen_rman_backup_file

    -------------------------------------------
    FUNCTION fn_gen_rcvr_local_with_s_c (
        p_dbid                IN     VARCHAR2, -- DB ID from original DB (if it is to be set the same (null if not setting this)
        p_db_name             IN     VARCHAR2, -- Database NAME - Matching /zfssa/.../backupxx/<DB_NAME> - you can change later if needed or modify scripts
        p_db_unique_name      IN     VARCHAR2,         -- Database UNIQUE NAME
        p_oracle_base         IN     VARCHAR2,                  -- ORACLE_BASE
        p_oracle_home         IN     VARCHAR2,                  -- ORACLE_HOME
        p_db_instance_name    IN     VARCHAR2, -- instance name and number to be started on initial machine
        p_compute_nodes       IN     INTEGER,       -- number of compute nodes
        p_previous_asm_data   IN     VARCHAR2, -- previous DATA ASM disk group (like +DATA_DM) - Auxiliary
        p_current_asm_data    IN     VARCHAR2, -- current  DATA ASM disk group (like +DATA_WH) - Target
        p_previous_asm_reco   IN     VARCHAR2, -- previous RECO ASM disk group (like +RECO_DM) - Auxiliary
        p_current_asm_reco    IN     VARCHAR2, -- current  RECO ASM disk group (like +RECO_WH) - Target
        p_machine_name_1      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_2      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_3      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_4      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_5      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_6      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_7      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_machine_name_8      IN     VARCHAR2, -- machine name (adm name for db compute node)
        p_error_message       IN OUT VARCHAR2 -- If there is an error message (return code less than zero - then return message)
                                             )
        RETURN NUMBER
    IS
        /*

                    Purpose: Generate command script for rman Recovery for the same ZFS
                             When the SPfile and Control file are included

                    Assumptions:
                    1) A typical recovery in place does not need these scripts and normal recovery commands can be executed
                    2) These scripts in worksheet format are to recover a database on a different cluster(or node) from a common shared location (zfs)
                    3) Spfile and Control files are written with the same scripts provided from this generator in the same format and location
                    4) This is a 12c database - sql commands can be executed normally from rman
                    5) These scripts are put into a worksheet format and may need to be run in a nohup session or "screen"

                    Note: file format will be:
                    RMAN
                    rman_rec_wks_sc_<database unique name>_file_x_of_y.txt

                    MODIFICATION HISTORY
                    Person      Date        Comments
                    ---------   ------      -------------------------------------------
                    dcox        11/9/2015   Initial Build
                    dcox        11/10/2015  Many formatting and corrections after testing
                    dcox        11/13/2015  Multiple changes from testing (mostly formatting)
                    dcox        11/15/2015  Added catalog start with commands (for recoveries from other environments)
                    dcox        08-Jan-18   rebuild to make this generic


            */
        v_buffer             VARCHAR2 (32767); -- buffer for file to be written
        v_last_letter        VARCHAR2 (3);     -- last letter in instance name
        v_sqlcode            NUMBER;                                -- sqlcode
        v_pfile_name         VARCHAR2 (3000);      -- pfile directory and name
        v_controlfile        VARCHAR2 (3000); -- controlfile directory and name
        v_spfile_name        VARCHAR2 (3000);                        -- spfile
        v_worksheet_base     VARCHAR2 (3000);  -- base filename for worksheets
        v_line_no            INTEGER := 0;                    -- debug line no
        v_file_handle        UTL_FILE.file_type;                -- file handle
        v_directory          VARCHAR2 (1000) := vgc_directory; -- RMAN directory
        v_filename           VARCHAR2 (200);                       -- filename

        v_version            VARCHAR2 (100) := 'Script Version 1.0.0'; -- script version
        vc_action   CONSTANT VARCHAR2 (100) := '# ACTION ';          -- Action
        vc_info     CONSTANT VARCHAR2 (100) := '# INFO ';       -- information
        vc_rman     CONSTANT VARCHAR2 (100) := '# RMAN COMMAND'; -- rman command
        vc_sh       CONSTANT VARCHAR2 (100) := '# SH COMMAND'; -- korn/bash shell  command
        v_available          VARCHAR2 (32767); -- variable to create Available service names
        v_preferred          VARCHAR2 (32767); -- variable to create preferred service names
        v_channel_no         VARCHAR2 (100);       -- channel no placeholder -
    BEGIN
        v_line_no := 100;                                     -- debug line no

        -- Check Parameters --------------------------
        -- Check DBID
        IF p_dbid IS NULL
        THEN
            DBMS_OUTPUT.put_line ('No DBID set will use the default');
        END IF;

        -- Check DB  Name
        IF p_db_name IS NULL
        THEN
            raise_application_error (-20002, 'DB Name is null');
        END IF;

        ------------
        -- Check Instance Name
        IF p_db_instance_name IS NULL
        THEN
            raise_application_error (-20003, 'Instance Name is null');
        END IF;

        -- Check for instance number
        v_last_letter :=
            SUBSTR (p_db_instance_name, LENGTH (p_db_instance_name));

        IF v_last_letter NOT IN ('0',
                                 '1',
                                 '2',
                                 '3',
                                 '4',
                                 '5',
                                 '6',
                                 '7',
                                 '8',
                                 '9')
        THEN
            raise_application_error (
                -20004,
                'Instance number not specified on Instance Name');
        END IF;

        -----------
        -- Check for more null parameters that should be populated

        IF p_oracle_base IS NULL
        THEN
            raise_application_error (-20005, 'p_oracle_base is not defined');
        END IF;

        IF p_oracle_home IS NULL
        THEN
            raise_application_error (-20005, 'p_oracle_home is not defined');
        END IF;

        IF p_previous_asm_data IS NULL
        THEN
            raise_application_error (-20005,
                                     'p_previous_asm_data is not defined');
        END IF;

        IF p_current_asm_data IS NULL
        THEN
            raise_application_error (-20005,
                                     'p_current_asm_data is not defined');
        END IF;

        IF p_previous_asm_reco IS NULL
        THEN
            raise_application_error (-20005,
                                     'p_previous_asm_reco is not defined');
        END IF;

        IF p_current_asm_reco IS NULL
        THEN
            raise_application_error (-20005,
                                     'p_current_asm_reco is not defined');
        END IF;

        v_line_no := 500;                                     -- debug line no

        -- Base output file names
        v_worksheet_base :=
            'rman_recovery_sc_' || LOWER (p_db_name) || '_file_';

        -------------------------------------------
        -- Worksheet 1 Start
        --------------------------------------------
        -- Add DB to /etc/oratab
        v_buffer :=
               v_buffer
            || vc_action
            || ' Add database to /etc/oratab files - All nodes '
            || CHR (10)
            || CHR (10);

        -- add supporting directories
        v_buffer :=
               v_buffer
            || vc_action
            || ' Add supporting directories - All nodes '
            || CHR (10)
            || CHR (10);
        v_buffer := v_buffer || vc_sh || CHR (10) || CHR (10);
        v_buffer :=
            v_buffer || 'cd ' || p_oracle_base || '/admin' || CHR (10);
        v_buffer :=
               v_buffer
            || 'mkdir '
            || p_db_unique_name
            || '; cd '
            || p_db_unique_name
            || CHR (10);
        v_buffer :=
               v_buffer
            || 'mkdir -p adump dpdump hdump pfile '
            || CHR (10)
            || CHR (10);
        v_buffer := v_buffer || vc_info || 'adump - audit file destination
                            The first default value is:
                            ORACLE_BASE/admin/DB_UNIQUE_NAME/adump
                            The second default value is:
                                ORACLE_HOME/rdbms/audit

                            dpdump - data pump directory
                            hdump - HA Log files
                            pfile - pfile directory' || CHR (10) || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || ' Verify space on ASM'
            || CHR (10)
            || CHR (10);

        v_buffer :=
            v_buffer || vc_sh || ' Verify space on hugepages' || CHR (10);
        v_buffer :=
            v_buffer || 'grep -i huge /proc/meminfo' || CHR (10) || CHR (10);

        v_buffer := v_buffer || vc_sh || ' Verify ORACLE_SID' || CHR (10);
        v_buffer := v_buffer || 'echo $ORACLE_SID' || CHR (10) || CHR (10);

        v_buffer := v_buffer || vc_sh || ' Verify ORACLE_BASE' || CHR (10);
        v_buffer := v_buffer || 'echo $ORACLE_BASE' || CHR (10) || CHR (10);

        v_buffer := v_buffer || vc_sh || '  Verify ORACLE_HOME' || CHR (10);
        v_buffer := v_buffer || 'echo $ORACLE_HOME' || CHR (10) || CHR (10);

        -- Verify PATH
        v_buffer := v_buffer || vc_sh || '  Verify PATH' || CHR (10);
        v_buffer := v_buffer || 'echo $PATH' || CHR (10) || CHR (10);

        v_buffer :=
               v_buffer
            || vc_sh
            || ' Get the file name for the spfile '
            || CHR (10);
        v_buffer := v_buffer || 'ls -lrt ' || vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_buffer := v_buffer || '01cf/';
        ELSE
            v_buffer := v_buffer || '/';
        END IF;

        v_buffer :=
            v_buffer || p_db_name || '/spfile*' || CHR (10) || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || ' Find DBID from original DB if this is to be recovered (not needed if this is a duplication)'
            || CHR (10)
            || CHR (10);

        -----------------------------------
        -- End Worksheet 1
        -----------------------------------

        --- WRITE WORKSHEET 1
        v_filename := v_worksheet_base || '1_of_4.txt';

        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- Add filename and header to buffer
        v_buffer :=
               '# '
            || v_filename
            || CHR (10)
            || '#'
            || CHR (10)
            || '# This file was generated on '
            || TO_CHAR (SYSDATE, 'YYYY MMDD HH24:MI:SS')
            || ' '
            || v_version
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || CHR (10)
            || v_buffer;

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);

        ------------------------------------
        -- Start Worksheet 2
        ------------------------------------

        -- Login comment
        v_buffer := v_buffer || vc_sh || ' Login to RMAN' || CHR (10);
        v_buffer :=
               v_buffer
            || 'rman target / nocatalog | tee /home/oracle/dba/log/rman_'
            || p_db_unique_name
            || '_recovery_'
            || TO_CHAR (SYSDATE, 'YYYY_MMDD')
            || '.log append'
            || CHR (10);

        -- set echo on
        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'set echo on;'
            || CHR (10)
            || CHR (10);

        -- DBID set
        IF p_dbid IS NULL
        THEN
            v_buffer :=
                   v_buffer
                || vc_action
                || ' Set DBID <ID> if this is a true recovery - it can be a new ID for duplication - DBID not provided'
                || CHR (10);
        ELSE
            v_buffer := v_buffer || vc_rman || CHR (10);
            v_buffer :=
                v_buffer || 'set dbid ' || p_dbid || CHR (10) || CHR (10);
        END IF;

        -- Nomount
        v_buffer := v_buffer || vc_rman || CHR (10);
        v_buffer := v_buffer || 'startup nomount;' || CHR (10) || CHR (10);

        ---------------------------
        -- File Definitions
        -- Set pfile and spfile dir and names
        v_pfile_name :=
               p_oracle_base
            || '/admin/'
            || p_db_unique_name
            || '/pfile/init'
            || UPPER (p_db_name)
            || '.ora';

        v_controlfile := vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_controlfile := v_controlfile || '01cf/';
        ELSE
            v_controlfile := v_controlfile || '/';
        END IF;

        v_controlfile :=
               v_controlfile
            || UPPER (p_db_name)
            || '/control_'
            || UPPER (p_db_name)
            || '.bkp';

        -- add some performance tuning for exadata zfs connection
        v_buffer :=
               v_buffer
            || vc_rman
            || 'add some performance tuning for exadata zfs connection '
            || CHR (10)
            || 'alter system set "_backup_disk_bufcnt"=64 scope=memory sid=''*'';'
            || CHR (10)
            || 'alter system set "_backup_disk_bufsz"=1048576 scope=memory sid=''*'';'
            || CHR (10)
            || 'alter system set "_backup_file_bufcnt"=64 scope=memory sid=''*'';'
            || CHR (10)
            || 'alter system set "_backup_file_bufsz"=1048576 scope=memory sid=''*'';'
            || CHR (10);

        -- set nls for timestamps
        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD HH24:MI:SS";'
            || CHR (10)
            || CHR (10);

        -- restore spfile
        v_buffer :=
               v_buffer
            || vc_rman
            || 'restore spfile '
            || CHR (10)
            || 'restore spfile from '''
            || '<spfile_found in action from worksheet 1>'
            || ''';'
            || CHR (10)
            || CHR (10);

        -- Create pfile from spfile
        v_buffer :=
               v_buffer
            || vc_rman
            || ' create pfile'
            || CHR (10)
            || 'create pfile='''
            || v_pfile_name
            || ''' from spfile;'
            || CHR (10)
            || CHR (10);

        -- Shutdown
        v_buffer := v_buffer || 'shutdown immediate;' || CHR (10) || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || ' Keep this RMAN session active for the next worksheet'
            || CHR (10)
            || CHR (10);

        -----------------------------------
        -- End Worksheet 2
        -----------------------------------
        --- WRITE WORKSHEET 2
        v_filename := v_worksheet_base || '2_of_4.txt';

        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- Write buffer for file 2
        -- Add filename and header to buffer
        v_buffer :=
               '# '
            || v_filename
            || CHR (10)
            || '#'
            || CHR (10)
            || '# This file was generated on '
            || TO_CHAR (SYSDATE, 'YYYY MMDD HH24:MI:SS')
            || ' '
            || v_version
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || CHR (10)
            || v_buffer;

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);

        -----------------------------------
        -- Start of  Worksheet 3
        -----------------------------------
        -- Verify following parameters (minimum)
        v_buffer :=
               v_buffer
            || vc_action
            || '############ DO THE FOLLOWING ################# '
            || CHR (10)
            || CHR (10)
            || '# Verify the following parameters (minimum) - Change as needed - BELOW ARE SUGGESTIONS - YOU NEED TO VERIFY'
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.audit_file_dest - use '
            || p_oracle_base
            || '/admin/'
            || p_db_unique_name
            || '/adump'
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.cluster_database=false -- going to single instance?'
            || CHR (10)
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.cluster interconnects - see ip addr'
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.control_files - pick up and set after controlfile restore - remove for now'
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.db_create_file_dest='''
            || p_current_asm_data
            || ''''
            || CHR (10);

        v_buffer :=
            v_buffer || '#ï    *.db_create_online_log_dest_1' || CHR (10);
        v_buffer :=
            v_buffer || '#ï    *.db_create_online_log_dest_2' || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.db_file_name_convert=''+'
            || p_previous_asm_data
            || '/'
            || p_db_name
            || ''',''+'
            || p_current_asm_data
            || '/'
            || p_db_name
            || ''',''+'
            || p_previous_asm_reco
            || '/'
            || p_db_name
            || ''',''+'
            || p_current_asm_reco
            || '/'
            || p_db_name
            || ''''
            || CHR (10);
        v_buffer := v_buffer || '#ï    db_name - verify' || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.db_recovery_file_dest=''+'
            || p_current_asm_reco
            || ''''
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#ï    *.db_unique_name='''
            || p_db_unique_name
            || ''''
            || CHR (10);
        v_buffer :=
            v_buffer || '#ï    *.dg_broker_config_file1' || CHR (10);
        v_buffer :=
            v_buffer || '#ï    *.dg_broker_config_file2' || CHR (10);

        v_buffer :=
               v_buffer
            || '#ï    *.log_file_name_convert=''+'
            || p_previous_asm_data
            || '/'
            || p_db_name
            || ''',''+'
            || p_current_asm_data
            || '/'
            || p_db_name
            || ''',''+'
            || p_previous_asm_reco
            || '/'
            || p_db_name
            || ''',''+'
            || p_current_asm_reco
            || '/'
            || p_db_name
            || ''''
            || CHR (10);

        v_buffer :=
               v_buffer
            || '#ï    *.processes=1024 -- OR higher if needed'
            || CHR (10);

        v_buffer :=
               v_buffer
            || '#ï    *.remote_listener'
            || CHR (10)
            || CHR (10)
            || CHR (10);

        ------------------------------------------------------------
        -- Commands to start resore and recover

        ------------------------------------------------------------

        -- Startup
        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'startup force nomount pfile='''
            || v_pfile_name
            || ''';'
            || CHR (10)
            || CHR (10);

        -- Restore controlfile
        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'restore controlfile from '''
            || v_controlfile
            || ''';'
            || CHR (10)
            || CHR (10);                        -- always on backup01/<DBNAME>
        v_buffer :=
               v_buffer
            || vc_action
            || ' Record control paths and names and put in init file, make sure that they are on ASM'
            || CHR (10)
            || CHR (10);
        v_buffer :=
               v_buffer
            || vc_action
            || ' Modify Init file format - '
            || CHR (10)
            || '*.control_files= ''file1'''
            || CHR (10)
            || '*.control_files= ''file2'''
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'alter database mount;'
            || CHR (10)
            || CHR (10);

        ------------------------------
        ---- Build Catalag start with commands
        -----------------------------

        v_buffer :=
               v_buffer
            || vc_rman
            || ' If this restore is from a different environment, you may want to run the following catalog commands otherwise skip them'
            || CHR (10);

        -- one for cf
        v_buffer :=
               v_buffer
            || 'run'
            || CHR (10)
            || '{'
            || CHR (10)
            || 'catalog start with '''
            || vgc_head1_dir_prefix;

        IF vgc_zfs_bool = TRUE
        THEN
            v_buffer := v_buffer || '01cf/';
        ELSE
            v_buffer := v_buffer || '/';
        END IF;

        v_buffer :=
            v_buffer || UPPER (p_db_name) || ''';' || CHR (10) || CHR (10);

        -- Allocate Channels
        FOR ichannel IN 1 .. vgc_channel_upper_limit
        LOOP
            v_line_no := 1700;                                -- debug line no
            v_channel_no := LPAD (ichannel, 2, '0');    -- left padded integer

            -- one for each head
            IF MOD (ichannel, 2) != 0
            THEN
                v_buffer :=
                       v_buffer
                    || 'catalog start with '''
                    || vgc_head1_dir_prefix
                    || ''
                    || v_channel_no
                    || '/'
                    || UPPER (p_db_name)
                    || '''; noprompt'
                    || CHR (10);
            ELSE
                v_buffer :=
                       v_buffer
                    || 'catalog start with '''
                    || vgc_head2_dir_prefix
                    || ''
                    || v_channel_no
                    || '/'
                    || UPPER (p_db_name)
                    || '''; noprompt'
                    || CHR (10);
            END IF;
        END LOOP;                                 -- end allocate channel loop

        v_buffer :=
               v_buffer
            || '}'
            || CHR (10)
            || '/'
            || CHR (10)
            || CHR (10)
            || CHR (10);                              -- Couple of blank lines
        -----------------------------

        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'restore database;'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'recover database;'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_rman
            || ' Handle block change tracking issue'
            || CHR (10);
        v_buffer :=
               v_buffer
            || CHR (10)
            || 'ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;'
            || CHR (10);
        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE ''+'
            || p_current_asm_data
            || '/'
            || UPPER (p_db_unique_name)
            || '/block_change_tracking.ctf'';'
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_rman
            || ' (may have to use noresetlogs) '
            || CHR (10)
            || 'alter database open resetlogs ; '
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || ' change cluster ---> cluster_database=true - might work best to leave true on 12c'
            || CHR (10)
            || CHR (10);
        v_buffer :=
               v_buffer
            || vc_action
            || ' Remove db_file_name_convert and log_file_name_convert if desired'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'create spfile in new location'
            || CHR (10)
            || CHR (10);
        v_buffer :=
               v_buffer
            || ' create spfile=''+'
            || p_current_asm_data
            || '/'
            || UPPER (p_db_unique_name)
            || '/spfile'
            || UPPER (p_db_unique_name)
            || '.ora'' from pfile='''
            || v_pfile_name
            || ''';'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_rman
            || CHR (10)
            || 'shutdown immediate;'
            || CHR (10)
            || CHR (10);

        --------------------------------
        -- End of worksheet 3
        -------------------------------
        -- Write file 3

        v_filename := v_worksheet_base || '3_of_4.txt';

        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- Write buffer for file 3
        -- Add filename and header to buffer
        v_buffer :=
               '# '
            || v_filename
            || CHR (10)
            || '#'
            || CHR (10)
            || '# This file was generated on '
            || TO_CHAR (SYSDATE, 'YYYY MMDD HH24:MI:SS')
            || ' '
            || v_version
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || CHR (10)
            || v_buffer;

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);

        -----------------------------
        -- Start of worksheet 4
        ------------------------------

        -- comments
        v_buffer :=
            v_buffer || vc_sh || ' Add the srvctl registration' || CHR (10);

        -- run commands below to add cluster registraton
        v_buffer :=
               v_buffer
            || 'srvctl add database -d '
            || p_db_unique_name
            || ' -n '
            || p_db_name
            || ' -pwfile ''+'
            || p_current_asm_data
            || '/'
            || UPPER (p_db_unique_name)
            || '/orapw'
            || UPPER (p_db_unique_name)
            || '.pwd'' \'
            || CHR (10)
            || ' -o '
            || p_oracle_home
            || ' \'
            || CHR (10)
            || ' -c RAC -p ''+'
            || p_current_asm_data
            || '/'
            || UPPER (p_db_unique_name)
            || '/spfile'
            || UPPER (p_db_unique_name)
            || '.ora'' \ '
            || CHR (10)
            || ' -a "'
            || p_current_asm_data
            || ','
            || p_current_asm_reco
            || '" -t immediate'
            || CHR (10);

        v_buffer := v_buffer || vc_sh || ' Add instances' || CHR (10);

        -- machine 1 - instance 1
        IF p_machine_name_1 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'srvctl add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '1 -n '
                || p_machine_name_1
                || CHR (10);
        END IF;

        -- machine 2 - instance 2
        IF p_machine_name_2 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'srvctl add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '2 -n '
                || p_machine_name_2
                || CHR (10);
        END IF;

        -- machine 3 - instance 3
        IF p_machine_name_3 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '3 -n '
                || p_machine_name_3
                || CHR (10);
        END IF;

        -- machine 4 - instance 4
        IF p_machine_name_4 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '4 -n '
                || p_machine_name_4
                || CHR (10);
        END IF;

        -- machine 5 - instance 5
        IF p_machine_name_5 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '5 -n '
                || p_machine_name_5
                || CHR (10);
        END IF;

        -- machine 6 - instance 6
        IF p_machine_name_6 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '6 -n '
                || p_machine_name_6
                || CHR (10);
        END IF;

        -- machine 7 - instance 7
        IF p_machine_name_7 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '7 -n '
                || p_machine_name_7
                || CHR (10);
        END IF;

        -- machine 8 - instance 8
        IF p_machine_name_8 IS NOT NULL
        THEN
            v_buffer :=
                   v_buffer
                || 'add instance -d '
                || p_db_unique_name
                || ' -i '
                || p_db_name
                || '8 -n '
                || p_machine_name_8
                || CHR (10);
        END IF;

        v_buffer :=
               v_buffer
            || vc_sh
            || ' Check config'
            || CHR (10)
            || 'srvctl config database -d '
            || p_db_unique_name
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_sh
            || ' Add the password file into ASM'
            || CHR (10)
            || 'orapwd file=''+'
            || p_current_asm_data
            || '/'
            || UPPER (p_db_unique_name)
            || '/orapw'
            || UPPER (p_db_name)
            || '.pwd'' password=<PASSWORD> force=y format=12 dbuniquename='
            || UPPER (p_db_unique_name)
            || CHR (10)
            || CHR (10)
            || 'NOTE: For this error see MOS Note: Error "OPW-00019" Creating Password File In ASM For 12c Database (Doc ID 2021520.1)'
            || CHR (10)
            || CHR (10);

        -- Start database
        v_buffer :=
               v_buffer
            || vc_sh
            || ' Start database and resolve any issues - verify installation'
            || CHR (10)
            || 'srvctl start database -d '
            || p_db_unique_name
            || CHR (10)
            || CHR (10);

        /*-- Services

        --- XXXXXXX REPLACE WITH FUNCTION

        */
        v_buffer := v_buffer || vc_sh || CHR (10) || CHR (10);

        -- Create services
        FOR ichannel IN 1 .. vgc_channel_upper_limit
        LOOP
            v_buffer :=
                   v_buffer
                || 'srvctl add service -d '
                || p_db_unique_name
                || ' -service '
                || p_db_name
                || '_bkup'
                || LPAD (ichannel, 2, '0');
            v_available := NULL;
            v_preferred := NULL;

            FOR inodes IN 1 .. p_compute_nodes
            LOOP
                -- don't include compute node on same mod value
                IF MOD (inodes, p_compute_nodes) !=
                   MOD (ichannel, p_compute_nodes)
                THEN
                    v_available := v_available || p_db_name || inodes || ',';
                ELSE
                    v_preferred := p_db_name || inodes;
                END IF;
            END LOOP;                                                 -- Nodes

            v_available := SUBSTR (v_available, 1, LENGTH (v_available) - 1);
            v_buffer :=
                   v_buffer
                || ' -preferred '
                || v_preferred
                || ' -available '
                || v_available
                || CHR (10);
        END LOOP;

        v_buffer :=
               v_buffer
            || CHR (10)
            || CHR (10)
            || vc_sh
            || ' Start services'
            || CHR (10)
            || 'srvctl start service -d '
            || p_db_unique_name
            || CHR (10)
            || CHR (10);

        /*-- Services EMD
        */
        v_buffer := v_buffer || '--- XXXXXXX REPLACE WITH FUNCTION';

        v_buffer :=
               v_buffer
            || vc_action
            || 'Add TNS Entries'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || 'Discover / Register with OEM'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || 'Register RMAN Catalog'
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || vc_action
            || 'Add RMAN Backups - See Backup and Recovery Engineering Document'
            || CHR (10)
            || CHR (10);

        /*   v_buffer :=
                  v_buffer
               || vc_action
               || 'Emable Flashback - SQL> Alter database flashback on; - Verify flashback parameter db_flashback_retention_target first '
               || CHR (10)
               || CHR (10);*/

        -----------------
        --- End of Worksheet 4
        -----------------
        -- Write worksheet 4
        v_filename := v_worksheet_base || '4_of_4.txt';

        v_file_handle :=
            UTL_FILE.fopen (location       => v_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- Add filename and header to buffer
        v_buffer :=
               '# '
            || v_filename
            || CHR (10)
            || '#'
            || CHR (10)
            || '# This file was generated on '
            || TO_CHAR (SYSDATE, 'YYYY MMDD HH24:MI:SS')
            || ' '
            || v_version
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || CHR (10)
            || CHR (10)
            || v_buffer;

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);

        ------------------------
        -- END of Worksheet 4 Write
        ------------------------

        -- Write KSH file to register database

        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rcvr_local_with_s_c;      --function fn_gen_rcvr_local_with_s_c

    -- ****************************************************************

    FUNCTION fn_gen_rman_ksh_master (
        p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- add a Y to force an overwrite,
        p_file_name         IN OUT VARCHAR2, -- enter a name if it is different than the default
        p_error_message     IN OUT VARCHAR2                --error message out
                                           )
        RETURN VARCHAR2
    IS
        /*

                Purpose: Create the ksh executable to run all the rman scripts

                MODIFICATION HISTORY
                Person      Date        Comments
                ---------   ------      -------------------------------------------
                dcox        8-Jan-2018  Initial Build
                dcox        11-Feb-2018 Added code to handle standby's
                dcox        26-Feb-2018 Added sys_utility return to rman call

        */
        v_line_no            INTEGER := 0;                    -- debug line no
        v_buffer             VARCHAR2 (32767); -- cache buffer into variable for writing
        v_sqlcode            NUMBER;                              -- errorcode
        v_bfile_loc          BFILE; -- binary file location - to test if file exists
        v_file_handle        UTL_FILE.file_type;                -- file handle
        v_filename           VARCHAR2 (400) := vgc_default_backup_rman; -- executable file to backup rman
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
            || ' ${1}-database (lowercase) ${2}-LEVEL ${3}-Channels'
            || CHR (10);
        v_buffer :=
               v_buffer
            || '#'
            || CHR (10)
            || '#'
            || CHR (10)
            || '################'
            || CHR (10)
            || '# Generated by pkg_rman_script_gen_prd.fn_gen_rman_ksh_master on '
            || TO_CHAR (SYSDATE, 'dd-MON-yyyy HH24:MI:SS')
            || CHR (10)
            || '################'
            || CHR (10);

        v_buffer := v_buffer || '
#
# Purpose:
#
#       Who             Date            Description
#       --------        -----------     -------------------------------
#       dcox            08-Jan-18       rebuild to make this generic
#       dcox            11-Feb-2018     Added code to handle standbys
#
set -x # debug

VERSION="3.0.0"
echo "$VERSION "

# BASE Parameters
SCRIPT_NAME=`basename $0`
SUCCESS=0
NLS_DATE_FORMAT="dd-month-yyyy hh:mi:ss am"
export SCRIPT_NAME SUCCESS NLS_DATE_FORMAT

unset SQLPATH # make sure sqlpath is not set
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

display_usage  ()
{

        echo " "
        echo "  Usage: ${SCRIPT_NAME} P1-database instance name P2-LEVEL P3-Channels \n\n"
        echo "  ScriptName - Program name\n"
        echo "  P1 - Database instance - may need to change if this is executed for a different node - DB_NAME\n"
        echo "  P2 - Level 0-Full 1-Incremental, or m-Maintenance\n"
        echo "  P3 - Channels 02,04,06,08,10,12,14,16,18,20,22,24 - others can be configured, but may require some code changes below. Corrects for missing leading 0\n"
        echo "  P4 - DB_UNIQUE_NAME - used when DB_NAME is not equal to DB_UNIQUE_NAME\n"
        echo "  P5 - Database Role - P,S, or Null - for Physical, Standby or null- defaults to Physical\n"
        echo " "
        echo "  Version: ${VERSION}\n"
        echo " "
        echo " "
        exit 1
}

check_for_fail ()
{
    # check for success
                if [[ ${SUCCESS} != 0 ]]
                then
                        echo "Failure on ${SCRIPT_NAME}" | mailx -s "RMAN BACKUP - ${PROCESS} Failed - ${ORACLE_SID}--`hostname`" ${EMAIL_FAILURE}
            rm -f ${LOCKFILE}
            exit 1
                fi # end - check of success
}

check_logfile_errors ()
{

    export IGNORE_ERRORS="ORA-20998|RMAN-08138"

    if [[ -z ${LOG_FILE_TO_CHECK} ]]
    then
        echo "No Log File to Check"
        SUCCESS="1"; check_for_fail
    fi

    echo "Log File To Check: ${LOG_FILE_TO_CHECK}\n"

    # Check to see if there are errors to ignore
    if [[ -n $IGNORE_ERRORS ]]; then
        SUCCESS=`cat ${LOG_FILE_TO_CHECK} |egrep -v "$IGNORE_ERRORS" |egrep "ORA-|RMAN-" | wc -l`
        check_for_fail
    else
        SUCCESS=`cat ${LOG_FILE_TO_CHECK} |egrep "ORA-|RMAN-" | wc -l`
        SUCCESS=${?}; check_for_fail
    fi

}

make_default_directories ()
{
    if [[ -z $DB_UNIQUE_NAME ]]
    then
        echo "DB_UNIQUE_NAME not set correctly"
        success="1"; check_for_fail
    fi
    if [[ -z $DB_NAME ]]
    then
        echo "DB_NAME not set correctly"
        success="1"; check_for_fail
    fi

    # check for success
    mkdir -p '
            || vgc_head1_dir_prefix
            || '/$DB_NAME_UC
    mkdir -p '
            || vgc_head2_dir_prefix
            || '/$DB_NAME_UC
    mkdir -p '
            || vgc_head1_dir_prefix
            || '/$DB_NAME/rman/controlfile_auto
}

';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
               '
################
# MAIN
################

# Check Arguments
if [[ "$1" == "" ]] || [[ "$2" == "" ]] || [[ "$3" == "" ]]
then
  echo " "
  echo "Error : missing argument"
  display_usage;
else
        echo "Database (1): ${1}"
        echo "Level (2): ${2}"
        echo "Channels (3): ${3}"

fi


# Notification
#EMAIL_SUCCESS=david.cox2@domain.com # debug
#EMAIL_FAILURE=david.cox2@domain.com # debug
#EMAIL_REPORT=david.cox2@domain.com # debug
EMAIL_REPORT='
            || vgc_email_report
            || '
EMAIL_SUCCESS='
            || vgc_email_success
            || '
EMAIL_FAILURE='
            || vgc_email_failure
            || '
export EMAIL_REPORT EMAIL_SUCCESS EMAIL_FAILURE

CURRENT_TIME=`date +"%Y_%m_%d_%H_%M"`; export CURRENT_TIME

echo "Validating Channels"
# Validate Thread Count
case "${3}" in
02|04|06|08|10|12|14|16|18|20|22|24)
        echo "Channel Count ${3} is acceptable"
        CHANNELS=${3}
        ;;
2)
    CHANNELS="02"
    ;;
4)
    CHANNELS="04"
    ;;
6)
    CHANNELS="06"
    ;;
8)
    CHANNELS="08"
    ;;
*)
        echo "Channel not validated"
        display_usage
        exit 1
        ;;
esac

export CHANNELS
';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
               '

# Validate Level
if [[ ${2} = "0" ]] ||  [[ ${2} = "1" ]] || [[ ${2} = "m" ]]
then
        echo "Level is acceptable\n"
        LEVEL=${2}
else
        display_usage
fi
export LEVEL

export DB_UNIQUE_NAME=${4} # Defining Database unique name - only necessary when DB_NAME is not equal to DB_UNIQUE_NAME

DB_ROLE=${5}
export DB_ROLE=$(echo ${DB_ROLE} | tr "[:lower:]" "[:upper:]")

# validate - DB Role
if [[ -z $DB_ROLE ]]
then
    export DB_ROLE="P"
    echo "DB Role is Physical"
elif [[ ${DB_ROLE} = "S" ]]
then
    echo "DB Role is Standby"
else
    echo "DB Role is not P, S, or null - please reset parameter to run correctly."
    SUCCESS=1; check_for_fail # Function
fi # end validation check of DB_ROLE



# DIRECTORY Parameters
BIN_DIR='
            || vrec_directory.directory_path
            || '
RMAN_DIR='
            || vrec_directory.directory_path
            || '
LOG_DIR=${RMAN_DIR}/log
export RMAN_DIR LOG_DIR BIN_DIR
';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
            '
# Create Lock file - Script_DBNAME creates locks file to match
LOCKFILE=${LOG_DIR}/${SCRIPT_NAME}_${1}.lockfile; export LOCKFILE

echo "Lockfile: $LOCKFILE \n"

lockfile -r 1 $LOCKFILE
LOCK_RESPONSE=${?}

if [[ $LOCK_RESPONSE -ne 0 ]]
then
        echo "Mail that this file is locked and program not started\n"
        echo "Process already running and locked -  ${SCRIPT_NAME}" | mailx -s "RMAN BACKUP - ${PROCESS} Failed - ${ORACLE_SID}--`hostname`" ${EMAIL_FAILURE}
    # Send standard report - locked - can have different recipients - These always receive a report
        exit 1 # exit with error code
fi

';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer := '

# Get the database set
ORACLE_SID=${1} # Set oracle SID

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
echo "Oracle SID: ${ORACLE_SID}\n"
echo "Oracle Base: ${ORACLE_BASE}\n"
echo "Oracle Home: ${ORACLE_HOME}\n"

echo "Path: ${PATH}\n"
';

        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
            '
# SET DB_NAMEs - for use in File Names and other code
if [[ -z ${DB_UNIQUE_NAME} ]]
then
    # Only when null then use sid
    DB_NAME_LC=${ORACLE_SID%?};
    export DB_NAME_LC=$(echo ${DB_NAME_LC} | tr "[:upper:]" "[:lower:]")
    export DB_NAME_UC=$(echo ${DB_NAME_LC} | tr "[:lower:]" "[:upper:]")
    export DB_UNIQUE_NAME=${DB_NAME_LC}
    export DB_NAME=${DB_NAME_LC};

else
    -- otherwise use db unique name
    DB_NAME_LC=${DB_UNIQUE_NAME};
    export DB_NAME_LC=$(echo ${DB_NAME_LC} | tr "[:upper:]" "[:lower:]")
    export DB_NAME_UC=$(echo ${DB_NAME_LC} | tr "[:lower:]" "[:upper:]")
    DB_NAME=${ORACLE_SID%?};
    export DB_NAME=$(echo ${DB_NAME} | tr "[:upper:]" "[:lower:]")
fi
echo "DB Unique Name: ${DB_UNIQUE_NAME}\n"
echo "DB NAME LC: ${DB_NAME_LC}\n"
echo "DB NAME: ${DB_NAME}\n"

# end set Names

# Create the default target rman output directories - Function
make_default_directories


# Log/Trace files
LOG_FILE=$LOG_DIR/bkup_${CURRENT_TIME}_db_${DB_NAME_LC}_${CHANNELS}c_lv${LEVEL}.log
LOG_FILE_DR=$LOG_DIR/bkup_${CURRENT_TIME}_db_${DB_NAME_LC}_${CHANNELS}c_lv${LEVEL}dr.log
TRC_FILE=$LOG_DIR/trace_${CURRENT_TIME}_db_${DB_NAME_LC}_${CHANNELS}c_lv${LEVEL}.trc
MAINT_LOG_FILE=$LOG_DIR/bkup_${CURRENT_TIME}_db_${DB_NAME_LC}_lm_maint.log
MAINT_TRC_FILE=$LOG_DIR/bkup_${CURRENT_TIME}_db_${DB_NAME_LC}_lm_maint.trc
export  LOG_FILE TRC_FILE MAINT_LOG_FILEMAINT_TRC_FILE

# Skip services when a Standby - Run for Physical
if [[ ${DB_ROLE} = "P" ]]
then
    echo "Stop and Start Backup Services"
    # Stop and start the service to make sure services are evenly distributed
    chmod 770 ${RMAN_DIR}/rman_service_restart_${DB_NAME_LC}.ksh
    ${RMAN_DIR}/rman_service_restart_${DB_NAME_LC}.ksh

    srvctl status service -d ${DB_NAME_LC}
fi
# End - Skip services when a Standby - Run for Physical

';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
               '

# Parse case for level
case "${LEVEL}" in
0|1)
    case  "${DB_ROLE}" in
    "P")
    echo "Running Level ${LEVEL} on database ${ORACLE_SID}"
    export LOG_FILE_TO_CHECK=$LOG_FILE
    rman target SYS/'
            || fn_get_sys_utility
            || ' @${RMAN_DIR}/backup_${DB_NAME_LC}_${CHANNELS}c_l${LEVEL}.rman > $LOG_FILE 2>&1
    #rman target SYS/'
            || fn_get_sys_utility
            || ' @${RMAN_DIR}/backup_${DB_NAME_LC}_${CHANNELS}c_l${LEVEL}.rman trace=${TRC_FILE} > $LOG_FILE 2>&1

    SUCCESS=${?}; check_for_fail # Function
    ;;
    "S")
    echo "Running Level ${LEVEL} - dr on database ${ORACLE_SID}"
    export LOG_FILE_TO_CHECK=$LOG_FILE_DR
    rman target SYS/'
            || fn_get_sys_utility
            || ' @${RMAN_DIR}/backup_${DB_NAME_LC}_${CHANNELS}c_ldr${LEVEL}.rman  > $LOG_FILE_DR 2>&1
    #rman target SYS/'
            || fn_get_sys_utility
            || ' @${RMAN_DIR}/backup_${DB_NAME_LC}_${CHANNELS}c_ldr${LEVEL}.rman trace=$MAINT_TRC_FILE > $LOG_FILE_DR 2>&1

    SUCCESS=${?}; check_for_fail # Function
    ;;
    esac
    ;;
m)

    echo "Running Maintenance on database ${ORACLE_SID}"
    export LOG_FILE_TO_CHECK=$MAINT_LOG_FILE
    rman target / @${RMAN_DIR}/backup_${DB_NAME_LC}_lm.rman  > $MAINT_LOG_FILE 2>&1
    #rman target / @${RMAN_DIR}/backup_${DB_NAME_LC}_lm.rman trace=$MAINT_TRC_FILE > $MAINT_LOG_FILE 2>&1

    SUCCESS=${?}; check_for_fail # Function
    ;;
*)
        echo "Level was improperly specified"
        ;;
esac # end level checks
SUCCESS=${?}; check_for_fail

# Check Logfile for Errors like ORA- or RMAN-
check_logfile_errors

';
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_buffer :=
            '
case  "${DB_ROLE}" in
    "P")
    # Send standard report - when passed - can have different recipients - These always receive a report
    ${BIN_DIR}/rman_status.ksh ${ORACLE_SID} ${EMAIL_REPORT}  > ${LOG_DIR}/rman_status_${ORACLE_SID}.log 2>&1 &
    ;;
    "S")
    echo "Report: RMAN BACKUP Status SID: ${DB_NAME_LC} on ${SCRIPT_NAME} - see logs for details." | mailx -s "RMAN BACKUP - ${PROCESS} Succeeded - ${DB_NAME_LC}--`hostname`" ${EMAIL_SUCCESS}
    ;;
esac

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
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                SUBSTR ('Value of v_line_no=' || TO_CHAR (v_line_no), 1, 255));
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_ksh_master;             -- function fn_gen_rman_ksh_master

    ---------------------------------
    FUNCTION fn_gen_bkup_services (
        p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
        p_db_name              IN     VARCHAR2,            -- Database DB_NAME
        p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
        p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
        p_buffer               IN OUT VARCHAR2,        -- services list buffer
        p_error_message        IN OUT VARCHAR2                -- error message
                                              )
        RETURN NUMBER
    IS
        /*

                           Purpose: Generate the backup services for worksheet or any other need

                           MODIFICATION HISTORY
                           Person      Date        Comments
                           ---------   ------      -------------------------------------------
                           dcox        13-Jan-18   Pulled code out and making it a function for reuse

                   */

        v_buffer         VARCHAR2 (32767);                           -- buffer
        vc_sh   CONSTANT VARCHAR2 (100) := '# SH COMMAND'; -- korn/bash shell  command
        v_available      VARCHAR2 (32767); -- variable to create Available service names
        v_preferred      VARCHAR2 (32767); -- variable to create preferred service names
        v_channel_no     VARCHAR2 (100);             -- channel no placeholder
        v_sqlcode        NUMBER;                                   -- sql code
    BEGIN
        -- Services
        v_buffer := v_buffer || vc_sh || CHR (10) || CHR (10);

        -- Create services
        FOR ichannel IN 1 ..
                        NVL (p_number_of_services, vgc_channel_upper_limit)
        LOOP
            v_buffer :=
                   v_buffer
                || 'srvctl add service -d '
                || p_db_unique_name
                || ' -service '
                || p_db_name
                || '_bkup'
                || LPAD (ichannel, 2, '0');
            v_available := NULL;
            v_preferred := NULL;

            FOR inodes IN 1 .. p_compute_nodes
            LOOP
                -- don't include compute node on same mod value
                IF MOD (inodes, p_compute_nodes) !=
                   MOD (ichannel, p_compute_nodes)
                THEN
                    v_available := v_available || p_db_name || inodes || ',';
                ELSE
                    v_preferred := p_db_name || inodes;
                END IF;
            END LOOP;                                                 -- Nodes

            v_available := SUBSTR (v_available, 1, LENGTH (v_available) - 1);
            v_buffer :=
                   v_buffer
                || ' -preferred '
                || v_preferred
                || ' -available '
                || v_available
                || CHR (10);
        END LOOP;

        v_buffer :=
               v_buffer
            || CHR (10)
            || CHR (10)
            || vc_sh
            || ' Start services'
            || CHR (10)
            || 'srvctl start service -d '
            || p_db_unique_name
            || CHR (10)
            || CHR (10);

        v_buffer :=
               v_buffer
            || CHR (10)
            || CHR (10)
            || vc_sh
            || ' Start services'
            || CHR (10)
            || 'srvctl status  service -d '
            || p_db_unique_name
            || CHR (10)
            || CHR (10);

        p_buffer := v_buffer;
        p_error_message := 'Success';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_bkup_services;                 -- Function fn_gen_bkup_services

    ---------------------------------
    FUNCTION fn_gen_bkup_services_ss (
        p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
        p_db_name              IN     VARCHAR2,            -- Database DB_NAME
        p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
        p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
        p_buffer               IN OUT VARCHAR2,        -- services list buffer
        p_error_message        IN OUT VARCHAR2                -- error message
                                              )
        RETURN NUMBER
    IS
        /*

        Purpose: Generate the backup services stop and start commands

        MODIFICATION HISTORY
        Person      Date        Comments
        ---------   ------      -------------------------------------------
        dcox        13-Jan-18   Initial Build

        */

        v_buffer         VARCHAR2 (32767);                           -- buffer
        vc_sh   CONSTANT VARCHAR2 (100) := '# SH COMMAND'; -- korn/bash shell  command
        v_available      VARCHAR2 (32767); -- variable to create Available service names
        v_preferred      VARCHAR2 (32767); -- variable to create preferred service names
        v_channel_no     VARCHAR2 (100);             -- channel no placeholder
        v_sqlcode        NUMBER;                                   -- sql code
    BEGIN
        -- Services
        v_buffer := v_buffer || vc_sh || CHR (10) || CHR (10);
        v_buffer :=
               v_buffer
            || '# Ignore stopping and starting errors for services not created: '
            || CHR (10)
            || CHR (10);
        v_buffer := v_buffer || CHR (10) || '# Stopping ' || CHR (10);

        -- stop services
        FOR ichannel IN 1 ..
                        NVL (p_number_of_services, vgc_channel_upper_limit)
        LOOP
            v_buffer :=
                   v_buffer
                || 'srvctl stop service -d '
                || p_db_unique_name
                || ' -service '
                || p_db_name
                || '_bkup'
                || LPAD (ichannel, 2, '0')
                || CHR (10);
        END LOOP;

        v_buffer := v_buffer || CHR (10) || '# Starting ' || CHR (10);

        -- start services
        FOR ichannel IN 1 ..
                        NVL (p_number_of_services, vgc_channel_upper_limit)
        LOOP
            v_buffer :=
                   v_buffer
                || 'srvctl start service -d '
                || p_db_unique_name
                || ' -service '
                || p_db_name
                || '_bkup'
                || LPAD (ichannel, 2, '0')
                || CHR (10);
        END LOOP;

        p_buffer := v_buffer;
        p_error_message := 'Success';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_bkup_services_ss;           -- Function fn_gen_bkup_services_ss

    ---------------------------------
    FUNCTION fn_gen_file_to_create_bkupsvc (
        p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
        p_db_name              IN     VARCHAR2,            -- Database DB_NAME
        p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
        p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
        p_error_message        IN OUT VARCHAR2                -- error message
                                              )
        RETURN NUMBER
    IS
        /*

                Purpose: Generate a file to create the backup services

                MODIFICATION HISTORY
                Person      Date        Comments
                ---------   ------      -------------------------------------------
                dcox        13-Jan-18   Initial Build

                */
        v_sqlcode             NUMBER;                              -- sql code
        v_filename            VARCHAR2 (500);                      -- filename
        v_database            VARCHAR2 (30);                        -- db name
        v_buffer              VARCHAR2 (32767);             -- buffer for text
        v_return              NUMBER;                            -- error code
        v_code_change_block   VARCHAR2 (32767);                -- change block
        v_header              VARCHAR2 (500); -- header for file type and printing filename
        v_file_handle         UTL_FILE.file_type;               -- file handle
        v_line_no             NUMBER;                           -- line number
        v_close               VARCHAR2 (500);                -- close for file
    BEGIN
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       dcox            13-Jan-18       Initial Build
#
#
#
# Use this script to create rman backup services
#
#
';

        -- Check for database name
        IF p_db_name IS NOT NULL
        THEN
            v_database := UPPER (p_db_name);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        v_filename := LOWER ('rman_service_create_' || v_database || '.ksh');

        v_return :=
            fn_gen_bkup_services (
                p_db_unique_name       => p_db_unique_name, -- Database UNIQUE NAME
                p_db_name              => p_db_name,       -- Database DB_NAME
                p_compute_nodes        => p_compute_nodes, -- number of compute nodes
                p_number_of_services   => p_number_of_services, -- Number of services to create
                p_buffer               => v_buffer,    -- services list buffer
                p_error_message        => p_error_message     -- error message
                                                         );

        -- Check for error
        IF v_return < 0
        THEN
            raise_application_error (-20001, p_error_message);
        END IF;

        -- Create Header
        v_header :=
               '#!/bin/ksh'
            || CHR (10)
            || '# File: '
            || v_filename
            || CHR (10)
            || CHR (10)
            || 'set -x # debug on'
            || CHR (10)
            || CHR (10);

        -- Add closing for restart
        v_close :=
               CHR (10)
            || CHR (10)
            || '# Processing complete exit '
            || CHR (10)
            || 'exit 0'
            || CHR (10);

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- write buffer and clear
        UTL_FILE.put (
            file =>
                v_file_handle,
            buffer =>
                v_header || v_code_change_block || v_buffer || v_close);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);

        p_error_message := 'Success';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            UTL_FILE.fclose_all;
            RETURN v_sqlcode;
    END fn_gen_file_to_create_bkupsvc; -- function fn_gen_file_to_create_bkupsvc

    ---------------------------------
    FUNCTION fn_gen_file_to_ss_bkupsvc (
        p_db_unique_name       IN     VARCHAR2,        -- Database UNIQUE NAME
        p_db_name              IN     VARCHAR2,            -- Database DB_NAME
        p_compute_nodes        IN     VARCHAR2,     -- number of compute nodes
        p_number_of_services   IN     VARCHAR2 DEFAULT NULL, -- Number of services to create
        p_error_message        IN OUT VARCHAR2                -- error message
                                              )
        RETURN NUMBER
    IS
        /*

            Purpose: Generate a file to start and stop the backup services

            MODIFICATION HISTORY
            Person      Date        Comments
            ---------   ------      -------------------------------------------
            dcox        13-Jan-18   Initial Build

        */
        v_sqlcode             NUMBER;                              -- sql code
        v_filename            VARCHAR2 (500);                      -- filename
        v_database            VARCHAR2 (30);                        -- db name
        v_buffer              VARCHAR2 (32767);             -- buffer for text
        v_return              NUMBER;                            -- error code
        v_code_change_block   VARCHAR2 (32767);                -- change block
        v_header              VARCHAR2 (500); -- header for file type and printing filename
        v_file_handle         UTL_FILE.file_type;               -- file handle
        v_line_no             NUMBER;                           -- line number
        v_close               VARCHAR2 (500);                -- close for file
    BEGIN
        v_code_change_block :=
               '
#       Note: This script was automatically generated on '
            || TO_CHAR (SYSDATE, 'DD-MON-RR HH24:MI:SS')
            || '
#
#       Who             Date            Description
#       -----------     ------------    ----------------------------------
#       dcox            13-Jan-18       Initial Build
#
#
#
# Use this script to stop and restart rman backup services
#
#
';

        -- Check for database name
        IF p_db_name IS NOT NULL
        THEN
            v_database := UPPER (p_db_name);
        ELSE
            v_database := fn_get_dbun;
        END IF;

        v_filename := LOWER ('rman_service_restart_' || v_database || '.ksh');

        v_return :=
            fn_gen_bkup_services_ss (
                p_db_unique_name       => p_db_unique_name, -- Database UNIQUE NAME
                p_db_name              => p_db_name,       -- Database DB_NAME
                p_compute_nodes        => p_compute_nodes, -- number of compute nodes
                p_number_of_services   => p_number_of_services, -- Number of services to create
                p_buffer               => v_buffer,    -- services list buffer
                p_error_message        => p_error_message     -- error message
                                                         );

        -- Check for error
        IF v_return < 0
        THEN
            raise_application_error (-20001, p_error_message);
        END IF;

        -- Create Header
        v_header :=
               '#!/bin/ksh'
            || CHR (10)
            || '# File: '
            || v_filename
            || CHR (10)
            || CHR (10)
            || 'set -x # debug on'
            || CHR (10)
            || CHR (10);

        -- Add closing for restart
        v_close :=
               CHR (10)
            || CHR (10)
            || '# Processing complete exit '
            || CHR (10)
            || 'exit 0'
            || CHR (10);

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);

        -- write buffer and clear
        UTL_FILE.put (
            file =>
                v_file_handle,
            buffer =>
                v_header || v_code_change_block || v_buffer || v_close);
        v_buffer := NULL;
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 3100;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);

        p_error_message := 'Success';
        RETURN 0;
    EXCEPTION
        WHEN OTHERS
        THEN
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            UTL_FILE.fclose_all;
            RETURN v_sqlcode;
    END fn_gen_file_to_ss_bkupsvc;       -- function fn_gen_file_to_ss_bkupsvc

    ----------------------------------
    FUNCTION fn_gen_rman_ksh_status (
        p_force_overwrite   IN     VARCHAR2 DEFAULT NULL, -- 'Y'  in this will overwrite
        p_error_message     IN OUT VARCHAR2                --error message out
                                           )
        RETURN VARCHAR2
    IS
        /*

                Purpose: Create the ksh and SQL executable to run all the rman status

                MODIFICATION HISTORY
                Person      Date        Comments
                ---------   ------      -------------------------------------------
                dcox        8-Jan-2018  Initial Build
                dcox        21-Feb-2018 Added Tags

        */
        v_line_no            INTEGER := 0;                    -- debug line no
        v_buffer             VARCHAR2 (32767); -- cache buffer into variable for writing
        v_sqlcode            NUMBER;                              -- errorcode
        v_bfile_loc          BFILE; -- binary file location - to test if file exists
        v_file_handle        UTL_FILE.file_type;                -- file handle
        v_filename           VARCHAR2 (400); -- executable file to get rman status
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

        v_filename := 'rman_status.ksh';

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

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 200;
        v_buffer :=
               '#!/bin/ksh

# rman_status.ksh ${1}-instance ${2}-Email address list

set -x # debug on
#
# Purpose: Rman Status - runs status and returns html for last xx days of runs
#
#       Who             Date            Description
#       --------        -----------     -------------------------------
#       dcox            25-Aug-15       Initial Build (got some code from Jojos Tablespace Report - Thanks Jojo Nano)
#
#

#############
# Variables
#############

LOGRETAIN_DAYS=30
CURRENT_TIME=`date +"%Y_%m_%d_%H_%M"`; export CURRENT_TIME

SCRIPT_NAME=$(basename $0 .ksh)
SCRIPT_DIR=`dirname $0`

# Directory Parameters
SQL_DIR='
            || vrec_directory.directory_path
            || '
LOG_DIR=${SQL_DIR}/log
REPORT_NAME="RMAN BACKUP Status"

################
# FUnctions
################

display_usage  ()
{

        echo " "
        echo "  Usage: ${SCRIPT_NAME} P1-instance_name P2-emailList (comman seperated,double quoted)  \n\n"
        echo "    \n"
        echo " "
        echo " "
        exit 1
}

#############
## Main
##############

# check arguments
if [[ "$1" == "" ]]; then
  echo " "
  echo "Error : missing argument"
  set +x # debug off
  display_usage;
fi



# Parameters in
ORACLE_SID=${1}; export ORACLE_SID
DEST_EMAIL=${2}; export DEST_EMAIL


HTMLMARK="set markup html on spool on entmap off -
    head ''<title>$ORACLE_SID $REPORT_NAME</title> -
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

ORAENV_ASK=NO; export ORAENV_ASK
. /usr/local/bin/oraenv

#ORACLE
if [[ -z $ORACLE_BASE ]]
then
	ORACLE_BASE=/u01/app/oracle
fi

if [[ -z $ORACLE_HOME ]]
then
	ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/dbhome_1
fi

PATH=$PATH:$ORACLE_BASE:$ORACLE_HOME
export ORACLE_BASE ORACLE_HOME PATH

SPOOL_SUFFIX="html"
SPOOL_FILE=${LOG_DIR}/${SCRIPT_NAME}_${ORACLE_SID}_${CURRENT_TIME}.${SPOOL_SUFFIX}

set +x # debug off
sqlplus -s /nolog <<EOF
connect / as sysdba
WHENEVER SQLERROR EXIT FAILURE
$HTMLMARK

@$SQL_DIR/rman_status.sql $SPOOL_FILE
EXIT SUCCESS
EOF

if [ $? -ne 0 ]
then
    echo "Error : sqlplus failed"
    exit 1
fi

echo "Report Name: ${SPOOL_FILE} \n"

#Mail
## Mail option
if [ "$DEST_EMAIL" != "" ]; then
        echo "Sending report to " $DEST_EMAIL
        (
        echo "Subject: Report: $REPORT_NAME SID:${ORACLE_SID} -- `hostname`";
        echo "To: $DEST_EMAIL "
        echo "MIME-Version: 1.0";
        echo "Content-Type: text/html";
        echo "Content-Disposition: inline";
        cat  $SPOOL_FILE ;
        ) | /usr/sbin/sendmail $DEST_EMAIL

fi
set -x # debug on
#echo "Removing the following log files"
#/usr/bin/find ${LOGDIR} -name ${SCRIPT_NAME}_* -ctime +${REMOVE_AFTER_DAYS} | xargs rm

exit 0';

        v_line_no := 10000;                                   -- debug line no
        -- write buffer and clear
        UTL_FILE.put (file => v_file_handle, buffer => v_buffer);
        v_buffer := NULL;
        v_line_no := 11000;                                   -- debug line no
        UTL_FILE.fflush (file => v_file_handle);
        v_line_no := 1200;                                    -- debug line no
        UTL_FILE.fclose (file => v_file_handle);
        --------------------------------
        --------------------------------
        v_filename := 'rman_status.sql';

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
                || vrec_directory.directory_path
                || '/'
                || v_filename);
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
        END IF;

        -- Open File for script to be generated
        v_file_handle :=
            UTL_FILE.fopen (location       => vgc_directory,
                            filename       => v_filename,
                            open_mode      => 'w',
                            max_linesize   => 32000);
        v_line_no := 200;
        v_buffer := 'SET VERIFY OFF;
set echo off;
set linesize 999;
set pagesize 30000;
set head on ;
CLEAR COLUMNS;
set markup html on
set markup html entmap off

spool &1



COLUMN SESSION_KEY          FORMAT 999999999        HEADING ''KEY''
COLUMN INPUT_TYPE	    FORMAT A10
COLUMN STATUS		    FORMAT A10
COLUMN GB_PER_HR            FORMAT 999,999.9        HEADING ''GB/HR''
COLUMN END_TIME             FORMAT DATE             HEADING ''ENDED''
COLUMN OUTPUT_GB            FORMAT 9,999,999.999    HEADING ''OUTPUT GB''
COLUMN COMPRESSION_RATIO    FORMAT 99.99            HEADING ''COMP. RATIO''
COLUMN TIME_TAKEN_DISPLAY   FORMAT A10
COLUMN TAGS   FORMAT A50

SELECT a.session_key
           "SESSION_KEY",
       a.input_type
           "INPUT_TYPE",
       a.status
           "STATUS",
       ROUND (a.input_bytes / POWER (1024, 3) / (a.elapsed_seconds / 3600),
              3)
           "GB_PER_HR",
       TO_CHAR (end_time, ''mm/dd/yy hh24:mi'')
           "END_TIME",
       ROUND (a.output_bytes / POWER (1024, 3), 3)
           "OUTPUT_GB",
       ROUND (a.compression_ratio, 2)
           "COMPRESSION_RATIO",
       TO_CHAR (a.time_taken_display)
           "TIME_TAKEN_DISPLAY",
       (SELECT LISTAGG (tag, '','') WITHIN GROUP (ORDER BY tag)
        FROM (SELECT DISTINCT tag
              FROM gv$backup_piece d
              WHERE     d.start_time >= a.start_time
                    AND d.completion_time <= a.end_time
                    AND d.tag NOT LIKE ''TAG%''))
           tags
FROM v$rman_backup_job_details a
WHERE a.start_time > TRUNC (SYSDATE) - 32
ORDER BY a.start_time DESC;

exit 0';

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
            v_sqlcode := SQLCODE;
            p_error_message := SQLERRM;
            RETURN v_sqlcode;
    END fn_gen_rman_ksh_status;             -- function fn_gen_rman_ksh_master
END pkg_rman_script_gen;
/


-- End of DDL Script for Package PXDDBA.PKG_RMAN_SCRIPT_GEN