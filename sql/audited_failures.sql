SELECT OS_USERNAME,
       USERNAME,
       TO_CHAR(TIMESTAMP,'dd-mon-yy hh24:mi')"Event_Time",
       returncode,
       TERMINAl,
       DECODE(RETURNCODE,1017,'Invalid Username/Password',
                            28000,'Account Locked',
                         955,'Name Already Used',
                         942,'Table, View Already Exists',
                         1918,'User Does not Exist',
                         28007,'Password Cannot Be Reused',
                         922,'Missing or Invalid Option',
                         923,'Keyword Missing',
                         936,'Missing Expresion',
                         904,'Invalid Identifier',
                         911,'Invalid Character',
                         1536,'Space Quota Exceeded',
                         2289,'Sequence Does Not Exist',
                         957,'Duplicate Column Name',
                         2095,'Init Param Cannot Be Modified',
                         31,'Session Marked for Kill',
                         900,'invalid SQL statement',
                         1031,'insufficient privileges',
                         28003,'password verification failed',
                         3217,'temp tablespace issue',
                         28001,'the password has expired',
                         2067,'transaction or savepoint rollback required',
                         1119,'space issue',
                         ' ')"Reason"
FROM dba_audit_trail
WHERE returncode!=0
-- AND USERNAME='ADSSYSTEM'
AND TRUNC(TIMESTAMP) > TRUNC(SYSDATE - 7)
-- AND returncode IN (1017,28000)
ORDER BY TIMESTAMP;



