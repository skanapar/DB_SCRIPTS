select max(al.sequence#) "Last Seq Recieved", max(lh.sequence#) "Last Seq Applied" from v$archived_log al, v$log_history lh
/
