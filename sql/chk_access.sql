SELECT a.type,
       Substr(a.owner,1,30) owner,
       a.sid,
       Substr(a.object,1,30) object
FROM   v$access a
WHERE  a.owner NOT IN ('SYS','PUBLIC')
and object like 'SL_AE_ADJUSTMENTS%'
ORDER BY 1,2,3,4
/
