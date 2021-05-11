set lines 132 pages 100
col sess for a10
col machine for a30
select a.sess,a.sid,b.serial#,a.id1,a.id2,a.lmode,a.request,a.type,b.machine from (
SELECT DECODE(request,0,'Holder: ','Waiter: ') sess,sid,
id1, id2, lmode, 
request, type 
FROM V$LOCK 
WHERE (id1, id2, type) IN (SELECT id1, id2, type FROM V$LOCK WHERE request>0) ) a,
v$session b
where a.sid=b.sid
ORDER BY id1, request ;
