set serveroutput on
declare
ls_sql varchar2(200);
begin
 dbms_output.enable(1000000);
  for srec in ( select t.* , ' TABLE ' object_type
                  from dba_tables t
                  where  --object_type='TABLE' and
                     owner  in ( 'SYSADM')
                     order by 3 desc
                                    ) loop
               ls_sql := 'truncate table ' ||' '||srec.owner||'.'||srec.table_name ||' ';
           begin
            execute immediate  ls_sql;
           exception
           when others then
           dbms_output.put_line( sqlerrm);
           dbms_output.put_line(ls_sql);
           end;

  end loop;
  for srec in ( select o.*
                  from dba_objects o
                  where  object_type='VIEW' and
                     owner  in ( 'SYSADM')
                     order by 3 desc
                                    ) loop
               ls_sql := 'drop '|| srec.object_type ||' '||srec.owner||'.'||srec.object_name ;
           begin
            execute immediate  ls_sql;
           exception
           when others then
           dbms_output.put_line( sqlerrm);
           dbms_output.put_line(ls_sql);
           end;
  end loop;
exception
when others then
dbms_output.put_line( sqlerrm);
dbms_output.put_line(ls_sql);
raise;
end;
/
