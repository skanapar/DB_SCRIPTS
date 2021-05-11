set echo on
undefine end_user_name
CONNECT  c##dbv_acctmgr_root@&pdb
create user "&1" identified by &2
profile  C##END_USER_ACCT_PROFILE
PASSWORD EXPIRE
/
grant connect, ps_read to "&1"
/


CONNECT c##dbv_owner_root@&pdb
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', grantee => '"&1"', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT);

