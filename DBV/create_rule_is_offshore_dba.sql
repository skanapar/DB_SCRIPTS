BEGIN
 DBMS_MACADM.CREATE_FACTOR(
  factor_name       => 'CLIENT_PROG_NAME',
  factor_type_name  => 'Application',
  description       => 'Stores client program name that connects to database',
  rule_set_name     => NULL,
  validate_expr     => NULL,
  get_expr          => 'UPPER(SYS_CONTEXT(''USERENV'',''CLIENT_PROGRAM_NAME''))',
  identify_by       => DBMS_MACUTL.G_IDENTIFY_BY_METHOD,
  labeled_by        => DBMS_MACUTL.G_LABELED_BY_SELF,
  eval_options      => DBMS_MACUTL.G_EVAL_ON_SESSION,
  audit_options     => DBMS_MACUTL.G_AUDIT_ON_GET_ERROR,
  fail_options      => DBMS_MACUTL.G_FAIL_SILENTLY);
END;
/


BEGIN
 DBMS_MACADM.CREATE_RULE_SET(
  rule_set_name    => 'Limit SQL*Plus Access',
  description      => 'Limits access to SQL*Plus for offshore  DBA',
  enabled          => DBMS_MACUTL.G_YES,
  eval_options     => DBMS_MACUTL.G_RULESET_EVAL_ANY,
  audit_options    => DBMS_MACUTL.G_RULESET_AUDIT_OFF,
  fail_options     => DBMS_MACUTL.G_RULESET_FAIL_SHOW,
  fail_message     => 'SQL*Plus access not allowed for offshore DBA',
  fail_code        => 20461,
  handler_options  => DBMS_MACUTL.G_RULESET_HANDLER_OFF,
  handler          => NULL,
  is_static        => FALSE);
END;
/

BEGIN
DBMS_MACADM.CREATE_RULE(
 rule_name  => 'BLOCK_OFFSHORE_DBA',
 rule_expr  => 'DVF.F$SESSION_USER !=''OFFSHORE_DBA''  AND TRIM(UPPER(DVF.F$CLIENT_PROG_NAME)) =''SQLPLUS@PRASH11-WY9DF2 (TNS V1-V3)'' ' );
END;
/
BEGIN
DBMS_MACADM.CREATE_RULE(
 rule_name  => 'ALLOW_OTHERS',
 rule_expr  => 'DVF.F$SESSION_USER !=''OFFSHORE_DBA'' ');
END;
/

BEGIN
 DBMS_MACADM.ADD_RULE_TO_RULE_SET(
  rule_set_name => 'Limit SQL*Plus Access',
  rule_name     => 'BLOCK_OFFSHORE_DBA',
  rule_order    => 1);
END;
/
BEGIN
 DBMS_MACADM.ADD_RULE_TO_RULE_SET(
  rule_set_name => 'Limit SQL*Plus Access',
  rule_name     => 'ALLOW_OTHERS',
  rule_order    => 2);
END;
/


BEGIN
 DBMS_MACADM.CREATE_COMMAND_RULE(
  command         => 'CONNECT',
  rule_set_name   => 'Limit SQL*Plus Access',
  object_owner    => '%',
  object_name     => '%',
  enabled         => DBMS_MACUTL.G_YES);
END;
/


