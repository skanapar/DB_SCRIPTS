declare
  cursor opencur is select * from v$open_cursor;
  ccount number;
begin
  select count(*) into ccount from v$open_cursor;
  dbms_output.put_line(' Num cursors open is '||ccount);
  ccount := 0;
-- get text of open/parsed cursors
  for vcur in opencur loop
    ccount := ccount + 1;
    dbms_output.put_line(' Cursor #'||ccount);
    dbms_output.put_line('     text: '|| vcur.sql_text);
  end loop;
end;
/
