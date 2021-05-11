declare
un varchar2(10);
fi varchar2(90);
mi varchar2(90);
la varchar2(90);
lastpart varchar2(90);
cursor c is
select name
from hris order by name;
rec c%rowtype;

begin
dbms_output.enable(1000000);
for rec in c loop
	lastpart:=substr(rec.name,instr(rec.name,',',-1)+1);
	la:=substr(rec.name,1,instr(rec.name,',',-1)-1);
	mi:=replace(substr(lastpart,instr(lastpart,' ')),' ');
	fi:=replace(substr(lastpart,1,instr(lastpart,' ')),' ');
	un:=substr(substr(fi,1,1)||la,1,7) ;
	dbms_output.put_line(rec.name||':'||fi||':'||mi||':'||la||':'||un);
end loop;
end;
/
