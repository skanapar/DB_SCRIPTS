set pages 55
set lines 160
col command format a40
col rule_set_name format a80
SELECT COMMAND, RULE_SET_NAME, enabled
 FROM DVSYS.DBA_DV_COMMAND_RULE;
