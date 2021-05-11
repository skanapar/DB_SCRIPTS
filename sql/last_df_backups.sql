select FILE#, max(COMPLETION_TIME) from V$BACKUP_DATAFILE group by  FILE# order by max(COMPLETION_TIME)
/
