set lines 80      
column name format a10
 
SELECT t.name, d.file# as, b.status      
FROM V$DATAFILE d, V$TABLESPACE t, V$BACKUP b       
WHERE d.TS#=t.TS# AND b.FILE#=d.FILE# and b.status <> 'NOT ACTIVE';