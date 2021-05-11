accept rmtdb prompt "db link name: "
set feedback off
set line 160
column name format a50
column "SRC->TGT" format a60

declare
localdb varchar2(10);
cursor c1 is 
select a.name pname, a.isdeprecated, a.value srcv, b.value tgtv
   from v$parameter a, v$parameter@&&rmtdb b
   where a.name=b.name
      and upper(a.value) <> upper(b.value)
      and upper(b.value) not like upper('%&&rmtdb%');
c c1%rowtype;
begin
dbms_output.enable(50000);
select name into localdb from v$database;
dbms_output.put_line('Differences '||localdb||' <=> '||upper('&&rmtdb'));
dbms_output.put_line('============================================================================='||chr(10));
for c in c1
loop
   dbms_output.put(c.pname);
   if c.isdeprecated = 'TRUE'
     then dbms_output.put_line(' (DEPRECATED)');
     else dbms_output.put_line('');
   end if;
   dbms_output.put_line(c.srcv||' <-> '||c.tgtv||chr(10));
   insert into pdiff values (c.pname, c.srcv, c.tgtv, decode(c.isdeprecated, 'TRUE', 'Y', 'N'));
end loop;
commit;
end;
/
