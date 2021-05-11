
SELECT a.type,
       Substr(a.owner,1,30) owner,
       a.sid,
       Substr(a.object,1,30) object
FROM   v$access a
WHERE  a.owner NOT IN ('SYS','PUBLIC')
ORDER BY 1,2,3,4
/
