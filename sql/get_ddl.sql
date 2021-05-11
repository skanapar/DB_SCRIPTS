set line 5000
set long 2000000
set pages 0
set serveroutput on
set termout on
select sys.DBMS_METADATA.GET_DDL(object_type => upper('&1'), name => upper('&3'), schema => upper('&2')) 
from dual;
