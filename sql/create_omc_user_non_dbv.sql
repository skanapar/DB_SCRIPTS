create user C##OMC_USER  identified by M0n1T0ring_2020  profile c##END_USER_ACCT_PROFILE;
grant connect to C##OMC_USER container=all ;
grant select any dictionary to C##OMC_USER container=all;
grant create synonym to  C##OMC_USER container=all;
grant execute on sys.dbms_lock to c##omc_user container=all;
grant execute on sys.dbms_system  to c##omc_user container=all;
grant connect to C##OMC_USER container=all ;
