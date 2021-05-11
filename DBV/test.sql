CONNECT c##dbv_owner_root@FINDMO1
DBMS_MACADM.ADD_OBJECT_TO_REALM(
  realm_name  =>'PEOPLESOFT_SCHEMA',
  object_owner => 'SYSADM',
  object_name  => 'PS%'
  object_type  => 'TABLE');
