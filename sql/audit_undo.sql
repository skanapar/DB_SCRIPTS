
Tue Apr 08                                                                                                                                                                 page    1
                                                                      Default Audits Enabled on this Database

NOAUDIT ALTER DATABASE BY SYSTEM  ;
NOAUDIT ALTER DATABASE LINK BY SYSTEM  ;
NOAUDIT ALTER PROFILE BY SYSTEM  ;
NOAUDIT ALTER SESSION BY SYSTEM  ;
NOAUDIT ALTER SYSTEM BY SYSTEM  ;
NOAUDIT ALTER SYSTEM BY XXAPPS_RO  ;
NOAUDIT ALTER TABLESPACE BY SYSTEM  ;
NOAUDIT ALTER USER BY SYSTEM  ;
NOAUDIT AUDIT SYSTEM BY XXAPPS_RO  ;
NOAUDIT CLUSTER BY XXAPPS_RO  ;
NOAUDIT CONTEXT BY XXAPPS_RO  ;
NOAUDIT CREATE SESSION BY BRINKS  ;
NOAUDIT CREATE SESSION BY SYSTEM  ;
NOAUDIT CREATE SESSION BY XXAPPS_RO  ;
NOAUDIT DATABASE LINK BY XXAPPS_RO  ;
NOAUDIT DIMENSION BY XXAPPS_RO  ;
NOAUDIT DIRECTORY   ;
NOAUDIT DIRECTORY BY XXAPPS_RO  ;
NOAUDIT INDEX BY XXAPPS_RO  ;
NOAUDIT MATERIALIZED VIEW BY XXAPPS_RO  ;
NOAUDIT MINING MODEL BY XXAPPS_RO  ;
NOAUDIT NOT EXISTS BY XXAPPS_RO  ;
NOAUDIT PROCEDURE BY XXAPPS_RO  ;
NOAUDIT PROFILE BY XXAPPS_RO  ;
NOAUDIT PUBLIC DATABASE LINK BY XXAPPS_RO  ;
NOAUDIT PUBLIC SYNONYM BY XXAPPS_RO  ;
NOAUDIT ROLE BY XXAPPS_RO  ;
NOAUDIT ROLLBACK SEGMENT BY XXAPPS_RO  ;
NOAUDIT SELECT TABLE BY XXAPPS_RO  ;
NOAUDIT SEQUENCE BY XXAPPS_RO  ;
NOAUDIT SYNONYM BY XXAPPS_RO  ;
NOAUDIT SYSTEM AUDIT BY XXAPPS_RO  ;
NOAUDIT SYSTEM GRANT BY XXAPPS_RO  ;
NOAUDIT TABLE BY XXAPPS_RO  ;
NOAUDIT TABLESPACE BY XXAPPS_RO  ;
NOAUDIT TRIGGER BY XXAPPS_RO  ;
NOAUDIT TYPE BY XXAPPS_RO  ;
NOAUDIT UPDATE TABLE BY XXAPPS_RO  ;
NOAUDIT USER BY XXAPPS_RO  ;
NOAUDIT VIEW BY XXAPPS_RO  ;

Tue Apr 08                                                                                                                                                                 page    1
                                                                      Default Audits Enabled on this Database

-- Please correct the problem described in bug 6636804:
update sys.STMT_AUDIT_OPTION_MAP set option#=234
 where name ='ON COMMIT REFRESH';
commit;


Tue Apr 08                                                                                                                                                                 page    1
                                                                      Default Audits Enabled on this Database

-- Please correct the problem described in note 1529792.1:
insert into javaobj$ select object_id,
(select AUDIT$ from javaobj$ where rownum=1)
 from dba_objects where object_type='JAVA CLASS'
 and status='VALID' and object_id not in (select obj# from javaobj$);
commit;

