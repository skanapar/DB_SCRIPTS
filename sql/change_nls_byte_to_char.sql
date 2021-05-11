Set Feedback Off
Set Verify Off
Set Serveroutput On
Set Termout On

Exec Dbms_Output.Put_Line('Starting build select of columns to be altered');
/*
Drop Table Sys.Semantics$
/

Create Table Sys.Semantics$(S_Owner Varchar2(40),
S_Table_Name Varchar2(40),
S_Column_Name Varchar2(40),
S_Data_Type Varchar2(40),
S_Char_Length Number,
S_Updated Varchar2(1 Char))
/

Insert Into Sys.Semantics$
Select C.Owner, C.Table_Name, C.Column_Name, C.Data_Type, C.Char_Length, 'N'
From All_Tab_Columns C, All_Tables T
Where C.Owner = T.Owner
And C.Table_Name = T.Table_Name
-- exclude partitioned, temp and IOT tables, they have no tablespace
And T.Tablespace_Name Is Not Null
-- exclude invalid tables
And T.Status = 'VALID'
-- exclude recyclebin tables
And T.Dropped = 'NO'
-- only VARCHAR2 and CHAR columns are needed
And C.Data_Type In ('VARCHAR2', 'CHAR')
-- only need to look for tables who are not yet CHAR semantics.
And C.Char_Used = 'B'
-- exclude External tables
And C.Table_Name Not In (Select Table_Name From All_External_Tables Where Owner = C.Owner)
-- exclude MVIEWS
And  C.Table_Name Not In (Select Mview_Name From All_Mviews Where Owner = C.Owner)
-- exclude MVIEW logs
And  C.Table_Name Not In (Select Log_Table From All_Mview_Logs Where Log_Owner = C.Owner)
-- exclude AQ tables they give ORA-24005
And  C.Table_Name Not In (Select Queue_Table From All_queues Where Owner = C.Owner)
-- Adapt here the list of users you want to change
And C.Owner In ('SYSADM')
-- alternatively you can exclude Oracle provided users:
-- And T.Owner Not In
-- ('DBSNMP','MGMT_VIEW','SYSMAN','TRACESVR','AURORA$ORB$UNAUTHENTICATED',
-- 'AURORA$JIS$UTILITY$','OSE$HTTP$ADMIN','MDSYS','MDDATA','ORDSYS','OUTLN',
-- 'ORDPLUGINS','SI_INFORMTN_SCHEMA','CTXSYS','WKSYS','WKUSER','WK_TEST',
-- 'REPADMIN','LBACSYS','DVF','DVSYS','ODM','ODM_MTR','DMSYS','OLAPSYS',
-- 'WMSYS','ANONYMOUS','XDB','EXFSYS','DIP','TSMSYS','SYSTEM','SYS')
/
Commit
/
*/

Declare
Cursor C1 Is Select Rowid,S.* From Sys.Semantics$ S Where S_Updated='N';
V_Statement Varchar2(255);
V_Nc Number(10);
V_Nt Number(10);
Begin
dbms_output.enable(1000000000);
Execute Immediate
'select count(*) from sys.semantics$ where s_updated=''N''' Into V_Nc;
Execute Immediate
'select count(distinct s_table_name) from sys.semantics$ where s_updated=''N''' Into V_Nt;
Dbms_Output.Put_Line
('ALTERing ' || V_Nc || ' columns in ' || V_Nt || ' tables');
For R1 In C1 Loop
V_Statement := 'ALTER TABLE "' || R1.S_Owner || '"."' || R1.S_Table_Name;
V_Statement := V_Statement || '" modify ("' || R1.S_Column_Name || '" ';
V_Statement := V_Statement || R1.S_Data_Type || '(' || R1.S_Char_Length;
V_Statement := V_Statement || ' CHAR))';
-- To have the statements only uncomment the next line and comment the execute immediate
-- dbms_output.put_line(v_statement);
begin
Execute Immediate V_Statement;
Update Sys.Semantics$ Set S_Updated = 'Y' Where Rowid=R1.Rowid;
Commit;
exception when others then
dbms_output.put_line(sqlerrm);
end;
End Loop;
Dbms_Output.Put_Line('Done');
End;
/
