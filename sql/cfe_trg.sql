create or replace trigger cfe_trg
after update on employee
for each row
-- fierro 9/13/00
BEGIN
	if :new.cfe_code <> :old.cfe_code then
		insert into emp_log values
			(:new.ssn,sysdate,'EMPLOYEE.CFE_CODE',
			:old.cfe_code,:new.cfe_code,'U');
	end if;
END cfe_trg;
/
show errors
