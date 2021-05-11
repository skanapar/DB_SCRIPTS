declare

cursor c1 is
SELECT 
	level, s.username, s.sid, s.serial#, s.osuser, 
	s.lockwait, s.status, s.module, s.machine, s.program,
	s.seconds_in_wait, s.event,
	(select object_type||' '||owner||'.'||object_name 
	   from dba_objects where object_id=s.row_wait_obj#) obj_locked,
    s.logon_Time,
	(select rtrim(sql_text) from v$sqlarea 
	   where sql_id=s.sql_id and address=s.sql_address) as curr_sql,
	(select rtrim(sql_text) from v$sqlarea 
	   where sql_id=s.prev_sql_id and address=s.prev_sql_addr) as prev_sql
FROM   v$session s
WHERE TYPE<>'BACKGROUND'
 AND ( level > 1 or ( level = 1 and s.sid in (select blocking_session from v$session)))
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;
rec1 c1%ROWTYPE;
embdy varchar2(5000);
dbname varchar2(20);

procedure log(str2add varchar2) is
begin
embdy:=embdy||str2add||chr(10);
end;

begin

select name into dbname from v$database;
for rec1 in c1
loop
	log(chr(10));
	if rec1.level = 1
	then
		log('Blocker SID: '||rec1.sid);
		log('    Serial#: '||rec1.serial#);
		log('       User: '||rec1.username);
		log('    Machine: '||rec1.machine);
		log(' Logon Time: '||rec1.logon_time);
		log('   Last SQL: '||rec1.prev_sql);
		log('  Kill comm: ALTER SYSTEM KILL SESSION '''||rec1.sid||','||rec1.serial#||''';');
	else
		log('       -->   Blocked SID: '||rec1.sid);
		log('       -->       Serial#: '||rec1.serial#);
		log('       -->          User: '||rec1.username);
		log('       -->       Machine: '||rec1.machine);
		log('       -->   Wait (secs): '||rec1.seconds_in_wait);		
		log('       -->    Wait Event: '||rec1.event);
		log('       --> Object Locked: '||rec1.obj_locked);		
		log('       -->   SQL Waiting: '||rec1.curr_sql);
	end if;
end loop;
if length(embdy)>0
then
	embdy:='Blocking sessions detected:'||chr(10)||embdy;
	/*utl_mail.send(
		SENDER      => 'oracle@host',
		RECIPIENTS  => 'someone@company.com',
		SUBJECT     => 'Locks detected on '||dbname,
		MESSAGE     => embdy);*/
	dbms_output.enable(length(embdy)+20);
	dbms_output.put(embdy);
end if;
end;
/
