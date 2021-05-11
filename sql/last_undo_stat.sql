select * from v$undostat where end_time=(select max(end_time) from v$undostat)
/
