EXEC dbms_macadm.create_realm(realm_name => 'HR Schema', description => 'HR APP Schema ', enabled => 'Y', audit_options => 1, realm_type =>'0' );
EXEC dbms_macadm.add_object_to_realm(realm_name => 'HR Schema', object_owner => 'HR', object_name => 'EMPLOYEES', object_type => '%' );
 
