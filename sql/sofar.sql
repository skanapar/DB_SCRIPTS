SELECT sid, serial#, context, sofar, totalwork, round(sofar/totalwork*100,2) "% Complete", opname
FROM gv$session_longops
WHERE sofar <> totalwork
AND totalwork != 0
/
