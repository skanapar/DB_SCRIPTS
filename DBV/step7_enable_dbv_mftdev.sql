CONNECT c##dbv_owner_root@&pdb
set serveroutput on
DECLARE
  -- 1. declare a list type
  TYPE USER_TYPE_T IS TABLE OF VARCHAR2(30);
 
  -- 2. declare the variable of the list
  USERS_T USER_TYPE_T;
 
  -- 3. optional variable to store single values
  V_STR_VALUE VARCHAR2(30);
 
BEGIN
 
  -- 4. initialize the list of values to be iterated in a for-loop
  USERS_T := USER_TYPE_T('DEV_STB', 'DEV_ESS', 'DEV_OPSS', 'DEV_UMS', 'DEV_MFT', 'DEV_IAU_VIEWER', 'DEV_IAU_APPEND', 'DEV_IAU', 'DEV_MDS', 'DEV_WLS_RUNTIME', 'DEV_WLS');
 
  -- 5. iterating over the values
  FOR INDX IN USERS_T.FIRST..USERS_T.LAST
  LOOP
   
    V_STR_VALUE := USERS_T(INDX);
    dbms_output.put_line( V_STR_VALUE);
-- realm_type 1 is mandatory
dbms_macadm.create_realm(realm_name =>V_STR_VALUE||'_SCHEMA', description =>V_STR_VALUE|| ' MAIN Schema ', enabled => 'Y', audit_options => 1, realm_type =>'1' );
dbms_macadm.add_object_to_realm(realm_name => V_STR_VALUE||'_SCHEMA', object_owner => V_STR_VALUE , object_name => '%', object_type => '%' );
 dbms_macadm.add_auth_to_realm(realm_name => V_STR_VALUE||'_SCHEMA', grantee => V_STR_VALUE, rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_OWNER);
     
  END LOOP;     
END;


/
