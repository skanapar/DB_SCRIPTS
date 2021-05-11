set lines 132 pages 100 heading off
select 'Alter System Kill Session '||''''||sid||','||serial#||'''' ||';'
  from v$session
 where sid in( SELECT sid FROM V$LOCK WHERE (id1, id2, type) IN (SELECT id1, id2, type FROM V$LOCK WHERE request>0)  and request = 0 );
set heading on
