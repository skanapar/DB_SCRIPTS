declare
i integer :=0;
begin
DBMS_LOGMNR.ADD_LOGFILE(
LOGFILENAME => '/oradba/app/oracle/admin/vldbpd2j/arch/vldbpd2j_30513_1_779699070.arc', 
OPTIONS => DBMS_LOGMNR.NEW);
for i in 14..40
loop
DBMS_LOGMNR.ADD_LOGFILE(
LOGFILENAME => '/oradba/app/oracle/admin/vldbpd2j/arch/vldbpd2j_305'||i||'_1_779699070.arc', 
OPTIONS => DBMS_LOGMNR.addfile);
end loop;
end;
/
