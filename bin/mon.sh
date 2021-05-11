read -p "Enter Loop Delay (default 5): " delay

delay=${delay:-5}

echo Loop Delay $delay seconds

 

while true

do

date

sqlplus -S "/as sysdba" <<EOF

--alter session set container=FINLDV1
/

set linesize 300    

set pagesize 200

col event for a35

col obj for a30

col program for a15

col lcet for 99999

col id for 99

col pkg for a25

col SUBPROGRAM for a25

col sid for 99999

select con_id con, inst_id id,status,sid,substr(program,1,15) as program,sql_id,sql_child_number ch,sql_exec_id,event,
          (select distinct object_name from dba_procedures where object_id=PLSQL_ENTRY_OBJECT_ID) PKG,
           (select distinct PROCEDURE_NAME from dba_procedures where object_id=plsql_entry_object_id and SUBPROGRAM_ID=PLSQL_ENTRY_SUBPROGRAM_ID) AS SUBPROGRAM,
(select object_name from dba_objects where ROW_WAIT_OBJ#=object_id) as OBJ,last_Call_et lcet,final_blocking_session fbs 
from gv\$session  where username not in ('SYS1','SYSTEM1')
 and status='ACTIVE' and event <> 'class slave wait' order by last_call_et desc,inst_id,status,program;

exit;

EOF

sleep $delay

 

done

 
