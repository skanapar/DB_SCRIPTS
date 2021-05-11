/* 
DBMS_MACADM.DELETE_OBJECT_FROM_REALM(
  realm_name   IN VARCHAR2, 
  object_owner IN VARCHAR2, 
  object_name  IN VARCHAR2, 
  object_type  IN VARCHAR2);
*/

EXEC dbms_macadm.delete_object_from_realm(realm_name => 'HR Schema', object_owner => 'HR', object_name => '%', object_type => '%' );
