create or replace
TRIGGER EFT_ACCT_TRG1
BEFORE INSERT OR DELETE OR UPDATE ON EFT_ACCT
for each row
BEGIN
if inserting then
  insert into eft_acct@ihastg10
  values
   (:new.EA_USER_ID,
    :new.EA_PF_ID,
    :new.EA_MASK,
    :new.EA_ENABLED_IND,
    :new.EA_MASK_CHANGE_DATE,
    :new.EA_FIRST_INVALID_LOGIN_DATE,
    :new.EA_INVALID_LOGIN_COUNT,
    :new.EA_USER_CREATE_DATE,
    :new.EA_NOTIF_IND,
    :new.EA_UB_FLAG,
    :new.EA_PM_FLAG,
    :new.EA_UBFR_FLAG,
    :new.EA_PMFR_FLAG,
    :new.EA_HRCA_FLAG,
    :new.EA_BCC_FLAG);
end if;
if updating then
  update eft_acct@ihastg10 set
    EA_USER_ID=:new.EA_USER_ID,
    EA_PF_ID=:new.EA_PF_ID,
    EA_MASK=:new.EA_MASK,
    EA_ENABLED_IND=:new.EA_ENABLED_IND,
    EA_MASK_CHANGE_DATE=:new.EA_MASK_CHANGE_DATE,
    EA_FIRST_INVALID_LOGIN_DATE=:new.EA_FIRST_INVALID_LOGIN_DATE,
    EA_INVALID_LOGIN_COUNT=:new.EA_INVALID_LOGIN_COUNT,
    EA_USER_CREATE_DATE=:new.EA_USER_CREATE_DATE,
    EA_NOTIF_IND=:new.EA_NOTIF_IND,
    EA_UB_FLAG=:new.EA_UB_FLAG,
    EA_PM_FLAG=:new.EA_PM_FLAG,
:q
bash-2.03$ cat cr_trg.sql
create or replace
TRIGGER EFT_ACCT_TRG1
BEFORE INSERT OR DELETE OR UPDATE ON EFT_ACCT
for each row
BEGIN
if inserting then
  insert into eft_acct@ihastg10
  values
   (:new.EA_USER_ID,
    :new.EA_PF_ID,
    :new.EA_MASK,
    :new.EA_ENABLED_IND,
    :new.EA_MASK_CHANGE_DATE,
    :new.EA_FIRST_INVALID_LOGIN_DATE,
    :new.EA_INVALID_LOGIN_COUNT,
    :new.EA_USER_CREATE_DATE,
    :new.EA_NOTIF_IND,
    :new.EA_UB_FLAG,
    :new.EA_PM_FLAG,
    :new.EA_UBFR_FLAG,
    :new.EA_PMFR_FLAG,
    :new.EA_HRCA_FLAG,
    :new.EA_BCC_FLAG);
end if;
if updating then
  update eft_acct@ihastg10 set
    EA_USER_ID=:new.EA_USER_ID,
    EA_PF_ID=:new.EA_PF_ID,
    EA_MASK=:new.EA_MASK,
    EA_ENABLED_IND=:new.EA_ENABLED_IND,
    EA_MASK_CHANGE_DATE=:new.EA_MASK_CHANGE_DATE,
    EA_FIRST_INVALID_LOGIN_DATE=:new.EA_FIRST_INVALID_LOGIN_DATE,
    EA_INVALID_LOGIN_COUNT=:new.EA_INVALID_LOGIN_COUNT,
    EA_USER_CREATE_DATE=:new.EA_USER_CREATE_DATE,
    EA_NOTIF_IND=:new.EA_NOTIF_IND,
    EA_UB_FLAG=:new.EA_UB_FLAG,
    EA_PM_FLAG=:new.EA_PM_FLAG,
    EA_UBFR_FLAG=:new.EA_UBFR_FLAG,
    EA_PMFR_FLAG=:new.EA_PMFR_FLAG,
    EA_HRCA_FLAG=:new.EA_HRCA_FLAG,
    EA_BCC_FLAG=:new.EA_BCC_FLAG
    where ea_user_id=:old.ea_user_id;
end if;
if deleting then
    delete from eft_acct@ihastg10 where ea_user_id=:old.ea_user_id;
end if;
END;
