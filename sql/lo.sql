set linesize 400
set pagesize 40
col object_name format a25
col object_id format 999999 heading 'OBJ|ID'
col locked_mode format 999 heading 'OBJ|LCK'
col lmode format 999 heading 'SES|LCK'
col sid format 999
col status format a8
col Descrip format a10
col type format a4
col Blk heading 'BLK?'
col ORACLE_USERNAME for a20
col OS_USER_NAME for a20

spool /var/tmp/oracle/lo.lst
select d.osuser os_user_name,ltrim(rtrim(substr(e.name,1,10))) "DOING?",b.object_name,a.object_id,a.locked_mode,c.lmode,
       decode(c.lmode,0,'None',1,'Null',2,'Row-S',3,'Row-X',4,'Share',5,'S/Row-X',6,'Exclusive') Descrip,
       d.sid,d.serial#,d.status, c.ctime,decode(c.block,0,'No',1,'Yes') Blk,c.type
  from v$locked_object a, dba_objects b, v$lock c, v$session d ,sys.audit_actions e
 where a.object_id=b.object_id 
   and c.sid=a.session_id
   and c.sid=d.sid
  and e.action = d.command
  order by b.object_name,c.lmode desc,c.ctime;
spool off;
