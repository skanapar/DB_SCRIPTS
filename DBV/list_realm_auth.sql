set lines 200
col realm_name format a50
col grantee format a30
col auth_rule_set_name format a30
col auth_options format a30
SELECT REALM_NAME, GRANTEE, AUTH_RULE_SET_NAME, auth_options
 FROM DVSYS.DBA_DV_REALM_AUTH;

