declare
 uid number;
 l_result integer;
 sqltext varchar2(1000) := 'begin
dbms_job.run(job => 17);
end;';
 myint integer;
 begin
     select user_id into UID from all_users where username = 'ADMIN';
     myint:=sys.dbms_sys_sql.open_cursor();
     sys.dbms_sys_sql.parse_as_user(myint,sqltext,dbms_sql.native,UID);
     l_result:=sys.dbms_sys_sql.execute(myint);
     sys.dbms_sys_sql.close_cursor(myint);
 end;
/
