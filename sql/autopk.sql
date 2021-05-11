drop sequence booker.ppe_ctl_seq
/
create sequence booker.ppe_ctl_seq
start with 1 increment by 1
nomaxvalue nocycle
/
create or replace trigger booker.ppe_ctl_autopk
before insert on booker.ppe_ctl
for each row
begin
select ppe_ctl_seq.nextval into :new.ctl_id from dual;
end;
/