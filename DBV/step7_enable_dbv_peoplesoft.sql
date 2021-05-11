CONNECT c##dbv_owner_root@&pdb
EXEC dbms_macadm.create_realm(realm_name => 'PEOPLESOFT_SCHEMA', description => 'Peoplesoft MAIN Schema ', enabled => 'Y', audit_options => 1, realm_type =>'1' );
-- realm_type 1 is mandatory
EXEC dbms_macadm.add_object_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', object_owner => 'SYSADM', object_name => '%', object_type => '%' );
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', grantee => 'SYSADM', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', grantee => 'PEOPLE', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT);
BEGIN dbms_macadm.add_auth_to_realm(realm_name => 'Oracle Enterprise Manager',
 grantee => 'SYSADM',  rule_set_name => '',
 auth_options => DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT); END;
/
