select privilege, OWNER||'.'||TABLE_NAME granted_on, grantable from dba_tab_privs where grantee='&user'
and TABLE_NAME like '%&tablike%'
/
