-- eduardo fierro 10/06
-- set termout off
set trimspool on
set serveroutput on

create or replace procedure getsdehosts_proc as

countn integer := 0;
mailbody varchar2(4000);

cursor c1 is
	select distinct nodename, owner from sde.process_information;
c1r c1%rowtype;

procedure log ( message IN varchar2 ) is
wholestr varchar2(512);
begin
	wholestr := to_char(SYSDATE,'DD-MON-YYYY HH24:MI:SS')||': '||message;
	dbms_output.put_line(wholestr);
end log;

BEGIN

-- initialize output
dbms_output.enable(buffer_size => NULL);

-- log('Start Process: '||chr(10));
-- log('Loop thru connected users in SDE...');

for c1r in c1
loop
	select count(*) into countn from getsdehosts where nodename = c1r.nodename;
	if countn = 0 then
		insert into getsdehosts(nodename, owner) values(c1r.nodename, c1r.owner);
-- 		log('Found new host accessing this instance: '||c1r.nodename||' user:'||c1r.owner);
	end if;
end loop;
commit;

-- log('Finished checking processes...');

END;
/
