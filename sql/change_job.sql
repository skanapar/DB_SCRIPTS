declare
 uid number;
 l_result integer;
 sqltext varchar2(1000) := 
'begin
dbms_job.what(
  job => 17, 
  what => ''begin 
    update FINANCIALS.jelservice_configuration set value =''''false'''' where name = ''''IntervalArchiving.Enabled''''; 
    commit; 
    ADMIN.DW_PARTITION_UTIL.CREATE_PARTITIONS(''''FINANCIALS'''',SYSDATE+5); 
    update FINANCIALS.jelservice_configuration set value =''''true'''' where name = ''''IntervalArchiving.Enabled''''; 
    commit; 
  end;'');
end; 
';
 myint integer;
 begin
     select user_id into UID from all_users where username = 'ADMIN';
     myint:=sys.dbms_sys_sql.open_cursor();
     sys.dbms_sys_sql.parse_as_user(myint,sqltext,dbms_sql.native,UID);
     l_result:=sys.dbms_sys_sql.execute(myint);
     sys.dbms_sys_sql.close_cursor(myint);
 end;
/
