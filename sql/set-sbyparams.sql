undef standby1
undef standby2
undef primary
alter system set log_archive_config = 'DG_CONFIG=(&&standby1,&&standby2,&&primary)' scope=both sid='*';
alter system set log_archive_dest_2='SERVICE=&&standby1 ASYNC NOAFFIRM VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=&&standby1' sid='*' scope=both;
alter system set log_archive_dest_3='SERVICE=&&standby2 ASYNC NOAFFIRM VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=&&standby2' sid='*' scope=both;
alter system set log_archive_dest_state_2=defer scope=both;
alter system set log_archive_dest_state_3=defer scope=both;
alter system set STANDBY_FILE_MANAGEMENT=AUTO scope=both sid='*';
