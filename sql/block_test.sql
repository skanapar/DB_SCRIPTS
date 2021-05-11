prompt in another session, connect as A and:
prompt savepoint foo;;
prompt update ops$tkyte.t set x = x+1;;
prompt then in another session, connect as B and:
prompt update ops$tkyte.t set x = x+1;;
prompt then come back here and hit enter....
pause

select
(select username from v$session where sid=a.sid) blocker,
a.sid,
' is blocking ',
(select username from v$session where sid=b.sid) blockee,
b.sid
from v$lock a, v$lock b
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
/
select sid,
(select username from v$session s where s.sid = v$lock.sid) uname,
type, id1, id2,
(select object_name from user_objects where object_id = v$lock.id1) nm
from v$lock
where sid in (select sid from v$session where username in ('A','B','C',user) )
/

prompt in session A issue:
prompt rollback to foo;;
prompt note that B is blocked, then come back here and hit enter:
pause

select
(select username from v$session where sid=a.sid) blocker,
a.sid,
' is blocking ',
(select username from v$session where sid=b.sid) blockee,
b.sid
from v$lock a, v$lock b
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
/
select sid,
(select username from v$session s where s.sid = v$lock.sid) uname,
type, id1, id2,
(select object_name from user_objects where object_id = v$lock.id1) nm
from v$lock
where sid in (select sid from v$session where username in ('A','B','C',user) )
/

prompt Now in another session log in as C and:
prompt update ops$tkyte.t set x = x+1;;
prompt note: it does not block - b is still blocked.
prompt then in session A issue:
prompt commit;;
prompt and come back here an hit enter
pause

select
(select username from v$session where sid=a.sid) blocker,
a.sid,
' is blocking ',
(select username from v$session where sid=b.sid) blockee,
b.sid
from v$lock a, v$lock b
where a.block = 1
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
/
select sid,
(select username from v$session s where s.sid = v$lock.sid) uname,
type, id1, id2,
(select object_name from user_objects where object_id = v$lock.id1) nm
from v$lock
where sid in (select sid from v$session where username in ('A','B','C',user) )
/

prompt When A committed, B was released but instantly blocked by C...
prompt and that is where we are now...