set pages 500
set line 1000
set long 5000
set termout off
set trimspool on
column SCN format 99999999999999
column user format a8
column session_info format a80
column xid format a13
column segment_name format a30
column machine_name format a20
column logmnr_info format a105
column SQL_REDO format a80
column SQL_UNDO format a80

ALTER SESSION SET NLS_DATE_FORMAT = 'dd-mon-yyyy hh24:mi:ss';

declare
i integer :=0;
begin
DBMS_LOGMNR.ADD_LOGFILE(
LOGFILENAME => '/oradba/app/oracle/admin/vldbpd2j/arch/vldbpd2j_30535_1_779699070.arc',
OPTIONS => DBMS_LOGMNR.NEW);
for i in 35..50
loop
DBMS_LOGMNR.ADD_LOGFILE(
LOGFILENAME => '/oradba/app/oracle/admin/vldbpd2j/arch/vldbpd2j_305'||i||'_1_779699070.arc', 
OPTIONS => DBMS_LOGMNR.addfile);
end loop;
end;
/

EXECUTE DBMS_LOGMNR.START_LOGMNR( OPTIONS   => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.PRINT_PRETTY_SQL);

spool &1
SELECT 
(username||','|| 
scn||','|| 
timestamp||','|| 
COMMIT_TIMESTAMP||','|| 
session#||','|| 
serial#||','|| 
session_info||','||
XIDUSN || '.' || 
XIDSLT || '.' ||  
XIDSQN||','|| 
seg_owner||'.'||
seg_name||','|| 
machine_name) as logmnr_info,
SQL_REDO,
SQL_UNDO 
FROM V$LOGMNR_CONTENTS 
WHERE 
username not IN ('ITCM','SYS','SYSTEM','DBSNMP','UNKNOWN')
--username IN ('ITCM')
--and (scn in (10792103843483)
--or start_scn in (10792103843483)
--or commit_scn in (10792103843483))
--and XIDUSN=7
--and XIDSLT=20
--and XIDSQN=268141
order by timestamp
/
spool off

EXECUTE DBMS_LOGMNR.END_LOGMNR;
exit
