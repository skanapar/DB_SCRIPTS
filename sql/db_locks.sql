select a.sid sid,b.serial# serial#,a.ctime ctime,b.machine machine,b.status from (SELECT sid,ctime,lmode,request,id1,id2
                                          FROM V$LOCK
                                       WHERE (id1, id2, type) IN (SELECT id1, id2, type FROM V$LOCK WHERE request>0)
                ) a,v$session b
where a.sid=b.sid
  and a.ctime > 180
  and a.lmode = 6
  and a.request = 0
  and b.status='INACTIVE'
ORDER BY id1, request
/

