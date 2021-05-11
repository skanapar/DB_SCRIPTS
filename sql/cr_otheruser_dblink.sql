declare
uid number;
sqltext varchar2(1000) := 'create database link &link_name connect to &target_user identified by &target_user_password using ''&target_SID''';
myint integer;
begin
select user_id into uid from all_users where username like '&local_schema';
myint:=sys.dbms_sys_sql.open_cursor();
sys.dbms_sys_sql.parse_as_user(myint,sqltext,dbms_sql.native,UID);
sys.dbms_sys_sql.close_cursor(myint);
end ;