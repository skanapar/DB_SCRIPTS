set verify on
set feedback off
set pagesize 0
set timing off
set time off

spool /var/tmp/oracle/com.lst
prompt -- List of invalid procs,trigger,view,functions
select 'alter '||object_type||' '||owner||'.'||object_name||' compile;'
  from sys.dba_objects
 where object_type in ('PROCEDURE','TRIGGER','VIEW','FUNCTION')
   and status = 'INVALID'
order by owner, object_type, object_name;

prompt -- List of invalid package body,package
select 'alter package '||owner||'.'||object_name||
       decode(object_type,'PACKAGE BODY',' compile body;'
                         ,'PACKAGE',     ' compile;')
  from sys.dba_objects
 where object_type in ('PACKAGE BODY','PACKAGE')
   and status = 'INVALID'
order by owner, object_type desc, object_name;

spool off
