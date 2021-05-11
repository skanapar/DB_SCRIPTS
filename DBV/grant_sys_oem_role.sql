conn c##dbv_owner_root
EXEC dbms_macadm.add_auth_to_realm(realm_name => 'Oracle Enterprise Manager', grantee => 'SYS', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER)
