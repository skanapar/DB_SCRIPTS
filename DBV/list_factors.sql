set linesize 165
col name format a30
col factor_type_name format a50
col GET_EXPR format a80
SELECT NAME, FACTOR_TYPE_NAME, get_expr
 FROM DBA_DV_FACTOR
--WHERE FACTOR_TYPE_NAME='Authentication Method'
/
