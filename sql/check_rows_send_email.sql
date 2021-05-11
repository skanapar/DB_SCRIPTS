create or replace procedure mailtest as
msg varchar2(20000):= '';
rwct number(20) := 0;
l_Rec tab1%ROWTYPE;
BEGIN
        dbms_output.enable(2000);
        for l_rec in ( select * from tab1) loop
                msg := msg||rpad(l_rec.f1,10)||' '||lpad(l_rec.f2,10)||chr(10);
                rwct := rwct+1;
        end loop;
        if rwct > 0 then
                msg := 'Field1     '||'Field2    '||chr(10)||'========== '||'=========='||chr(10)||msg;
                UTL_MAIL.SEND (
                        sender => 'oracle@db3.wwex.com',
                        recipients => 'efierro@enkitec.com',
                        subject => 'Testing UTL_MAIL ...',
                        message => msg);
        else
                dbms_output.put_line('No data found, email was not sent');
        end if;
END;
/