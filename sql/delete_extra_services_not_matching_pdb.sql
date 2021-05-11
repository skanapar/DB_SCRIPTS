
set serveroutput on
declare pdb_name varchar2(30);
begin

select name into pdb_name from v$pdbs  where con_id>0;
for rec in (select name
              from dba_services
             where upper(name) not like upper(pdb_name||'%' ))
loop
dbms_output.put_line (rec.name);
dbms_service.delete_service(rec.name);
end loop;
end;
/

select name
from dba_services
/
   
