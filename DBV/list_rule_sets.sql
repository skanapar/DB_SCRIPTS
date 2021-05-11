set lines 200
col rule_set_name format a46
col description format a100
column oracle_supplied format a12
select rule_set_name, description, common, oracle_supplied
 from DBA_DV_RULE_SET
/
/*
 RULE_SET_NAME
 DESCRIPTION	
 ENABLED
 EVAL_OPTIONS_MEANING
 AUDIT_OPTIONS
 FAIL_OPTIONS_MEANING
 FAIL_MESSAGE
 FAIL_CODE
 HANDLER_OPTIONS
 HANDLER
 IS_STATIC
 COMMON 
 INHERITED
 ID#
 ORACLE_SUPPLIED
*/
/
