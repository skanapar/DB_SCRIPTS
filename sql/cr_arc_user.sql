create role audit_role;
grant CONNECT,  SELECT ANY DICTIONARY to audit_role;
grant SELECT on SYS.DBA_AUDIT_TRAIL to AUDIT_ROLE;
grant SELECT on SYS.V_$INSTANCE to AUDIT_ROLE;
grant SELECT on SYS.AUDIT$ to AUDIT_ROLE;

create user arc_user identified by values 'C74B79C654C8C526'
DEFAULT TABLESPACE AUDIT_SPACE
TEMPORARY TABLESPACE AUDIT_TEMP
profile audit_profile;

grant audit_role to arc_user;
