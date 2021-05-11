set serverout on

Begin
dbms_output.enable(10000);
for rec in (select sid, serial#
 from gv$session
where username ='HR')
loop
dbms_output.put_line('Sid, '|| rec.sid|| ' Serial#, '||  rec.serial#);
 DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION(sid=>rec.sid, serial#=>rec.serial#, sql_trace=>TRUE);
end loop;

end;
/
