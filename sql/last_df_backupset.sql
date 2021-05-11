SELECT b.set_stamp, b.checkpoint_time
FROM v$backup_datafile b, v$tablespace ts, v$datafile f
where b.incremental_level = 0
  AND INCLUDED_IN_DATABASE_BACKUP='YES'
  AND f.file#=b.file#
  AND f.ts#=ts.ts#
  AND b.checkpoint_time =
    (select max(checkpoint_time) from v$backup_datafile bd 
      where incremental_level = 0)