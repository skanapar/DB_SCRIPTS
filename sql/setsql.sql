declare
ctry varchar2(4);
sql_st varchar2(256);
cursor ab is
 select distinct ACCOUNTNBR from addressbook where rownum <1000001;
abrec ab%rowtype;
begin
ctry:='US';
for abrec in ab loop
sql_st := 'SELECT AccountNbr, LoginID, ReceiverID, CompanyName, AddressBookID, AddressType FROM'||chr(10)||
'ADDRESSBOOK WHERE country = :1 and AccountNbr = :2 ORDER BY UPPER(ReceiverID)';
execute immediate sql_st using ctry, abrec.accountnbr;
end loop;
end;
/
