set feedback off
set serveroutput on
declare
v_recovery_active varchar2(100);
begin
   select status 
     into v_recovery_active
     from  gv$managed_standby 
    where process like 'MRP%';
   exception
   when no_data_found
   then 
     begin
        dbms_output.put_line(' MRP not active');
        execute immediate 'alter database recover managed standby database using current logfile disconnect from session';
       dbms_output.put_line(' MRP started');
       exception when others then null;
     end;
end;
/
