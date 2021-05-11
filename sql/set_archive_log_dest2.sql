alter system set log_archive_dest_2='SERVICE=&1 ASYNC NOAFFIRM VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=&2' sid='*' scope=both;
alter system set log_archive_dest_state_2=enable scope=both;
