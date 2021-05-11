SELECT DECODE(
DBMS_NETWORK_ACL_ADMIN.check_privilege('utlmailpkg.xml', 'SYSTEM', 'connect'),
1, 'GRANTED', 0, 'DENIED', NULL) as "Connect",
DECODE(
DBMS_NETWORK_ACL_ADMIN.check_privilege('utlmailpkg.xml', 'SYSTEM', 'resolve'),
1, 'GRANTED', 0, 'DENIED', NULL) as "Resolve"
FROM dual
/
