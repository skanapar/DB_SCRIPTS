create procedure refresh_mv(mview varchar)
as
begin
dbms_mview.refresh(list => mview, method => 'C');
end;
/
