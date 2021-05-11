alter session set nls_date_format='dd-mon-yyyy hh24:mi:ss'
/
select  name,
        ctime "Date",
       decode(backup_type, 'L', 'Archive Log', 'D', 'Full', 'Incremental') backup_type,
        bsize "Size MB"
 from (select trunc(bp.completion_time) ctime
              , backup_type
              , round(sum(bp.bytes/1024/1024),2) bsize
       from v$backup_set bs, v$backup_piece bp
       where bs.set_stamp = bp.set_stamp
       and bs.set_count  = bp.set_count
       and bp.status = 'A'
       group by trunc(bp.completion_time), backup_type),
       v$database
order by 1, 2;
