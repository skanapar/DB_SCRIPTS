whenever sqlerror continue
CONNECT  c##dbv_acctmgr_root
create user C##OMC_USER  identified by &pass profile c##END_USER_ACCT_PROFILE;
grant connect to C##OMC_USER container=all ;
CONNECT c##dbv_owner_root
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'Oracle Enterprise Manager', grantee => 'C##OMC_USER', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER)
EXEC DVSYS.DBMS_MACADM.ADD_AUTH_TO_REALM( realm_name => 'Oracle Data Dictionary', grantee => 'C##OMC_USER');
host sleep 5

conn / as sysdba
create user C##OMC_USER  identified by M0n1T0ring_2020 profile c##END_USER_ACCT_PROFILE;
grant select any dictionary to C##OMC_USER container=all;
grant create synonym to  C##OMC_USER container=all;
grant execute on sys.dbms_lock to c##omc_user container=all;
grant execute on sys.dbms_system  to c##omc_user container=all;
host sleep 5

exit

--For Proplesoft
CONNECT c##dbv_owner_root@&pdb
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', grantee => 'C##OMC_USER', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT);

CONNECT SYSADM@&pdb


 GRANT SELECT ON SYSADM.PSSTATUS TO C##OMC_USER;
GRANT SELECT ON SYSADM.PSRELEASE TO C##OMC_USER;
GRANT SELECT ON SYSADM.PSPMAGENT TO C##OMC_USER;
GRANT SELECT ON SYSADM.PS_PTPMJMXUSER TO C##OMC_USER;
GRANT SELECT ON SYSADM.PSIBWSDLDFN TO C##OMC_USER;
GRANT SELECT ON SYSADM.PSIBSVCSETUP TO C##OMC_USER;
GRANT SELECT ON SYSADM.PS_PTSF_SRCH_ENGN TO C##OMC_USER;

conn / as sysdba
alter session set container=&pdb;
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PSSTATUS" FOR "SYSADM"."PSSTATUS";
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PSRELEASE" FOR "SYSADM"."PSRELEASE";
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PSPMAGENT" FOR "SYSADM"."PSPMAGENT";
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PS_PTPMJMXUSER" FOR "SYSADM"."PS_PTPMJMXUSER";
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PSIBWSDLDFN" FOR "SYSADM"."PSIBWSDLDFN";
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PSIBSVCSETUP" FOR "SYSADM"."PSIBSVCSETUP";
CREATE OR REPLACE SYNONYM "C##OMC_USER"."PS_PTSF_SRCH_ENGN" FOR "SYSADM"."PS_PTSF_SRCH_ENGN";


