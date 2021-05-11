begin
if ora_complexity_check ('&pass', chars => 12, uppercase => 2,
                           lowercase => 2, digit => 2, special => 1)
then
dbms_output.put_line(' Valid');
else
dbms_output.put_line(' INValid');
end if;
end;
/
