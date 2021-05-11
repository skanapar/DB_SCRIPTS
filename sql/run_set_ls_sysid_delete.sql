set serveroutput on
set termout on
set feedback off
set verify off
clear buffer
PROMPT About to move the line segments in a system into the "DELETE" system and company
ACCEPT SYS_NAME_PAR CHAR PROMPT "Enter System Name : "
begin
set_ls_sysid_delete('&&SYS_NAME_PAR');
end;
/
ACCEPT TOEXIT CHAR PROMPT "Press any key to exit..."
-- exit
