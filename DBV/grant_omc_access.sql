

EXEC dbms_macadm.add_auth_to_realm(realm_name => 'Oracle Enterprise Manager', grantee => 'C##OMC_USER', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
EXEC DVSYS.DBMS_MACADM.ADD_AUTH_TO_REALM( realm_name => 'Oracle Data Dictionary', grantee => 'C##OMC_USER');
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', grantee => 'C##OMC_USER', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT);


