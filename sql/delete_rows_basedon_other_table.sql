declare
cursor c1 is select product_id from telcustomer.product where tel_region = 'JAPAN';
prec c1%rowtype;
ct integer;
begin
dbms_output.enable(40000);
for prec in c1
loop
	delete from telcustomer.customer_price where product_id=prec.product_id;
	if ct >=1000 then
		commit;
		ct:= 0;
		dbms_output.put_line('commit...');
	else
		ct := ct+1;
	end if;
end loop;
commit;
end;
/
