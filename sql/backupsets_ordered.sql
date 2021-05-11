select checkpoint_time, set_stamp, dense_rank() over (order by checkpoint_time desc) cr 
  from v$backup_datafile bd
      group by checkpoint_time, set_stamp