declare
stmt varchar2(300);
hname varchar2(20);
uname varchar2(20);
begin
  select replace(replace(sys_context('USERENV','HOST'),'\','_'),'-',null),
    sys_context('USERENV','SESSION_USER')
  into hname,uname
  from dual;
  stmt := 'alter session set tracefile_identifier='''||hname||'_'||uname||'''';
  EXECUTE IMMEDIATE stmt;
  EXECUTE IMMEDIATE 'alter session set sql_trace=true';
end;
/
