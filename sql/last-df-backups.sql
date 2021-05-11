column file_name format a80
select df.name as file_name, bd.completion_time, df.status, df.enabled from v$datafile df join (select file#, max(completion_time) as completion_time from v$backup_datafile group by file#) bd on df.file# = bd.file# where bd.completion_time < sysdate - 2 order by 2 desc
/
