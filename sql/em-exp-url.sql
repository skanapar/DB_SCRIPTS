-- EM Express URLs
-- For HTTP
SELECT 'http://'||SYS_CONTEXT('USERENV','SERVER_HOST')||'.'||SYS_CONTEXT('USERENV','DB_DOMAIN')||':'||dbms_xdb_config.gethttpport()||'/em/' from dual;
SELECT 'http://'||SYS_CONTEXT('USERENV','SERVER_HOST')||':'||dbms_xdb_config.gethttpport()||'/em/' from dual;
-- For HTTPS
SELECT 'https://'||SYS_CONTEXT('USERENV','SERVER_HOST')||'.'||SYS_CONTEXT('USERENV','DB_DOMAIN')||':'||dbms_xdb_config.gethttpsport()||'/em/' from dual;
SELECT 'https://'||SYS_CONTEXT('USERENV','SERVER_HOST')||':'||dbms_xdb_config.gethttpsport()||'/em/' from dual;
