create or replace procedure BuildOnline ( sTableOwner varchar2, sTableToBeBuild varchar2, sIntermediateTable varchar2) as
/*****************************************************************************************
REM
REM Purpose:
REM	Build Tables online using online redifinition
REM  
REM Requirement: 
REM  	1] Assumes that intermediate table and source tables have indeticl indexes/constraints 
REM 	2] Create a log table under ops$oracle for logging info
REM 	   conn /
REM 	   create table logbuild (tabowner varchar2(35), tabname varchar2(35),sr# number,msg varchar2(500)); 
REM	   grant all on logbuild to public;
REM 		  
******************************************************************************************/
  sOwner 	varchar2(100);
  sTableToBuild varchar2(100);
  sIntermediate varchar2(100);
  sInsert 	varchar2(500);
  iCounter	number :=0; 
  nSanityIndex1 number; nSanityConstraints1 number; nSanityIndex2 number; nSanityConstraints2 number;
  Procedure LogMsg (str varchar2, icnt number) is
  Begin
    insert into ops$oracle.logbuild values ( sTableOwner, sTableToBeBuild, icnt, str); commit;     
  end;
begin
  sOwner 	:= upper(sTableOwner);
  sTableToBuild := upper(sTableToBeBuild);
  sIntermediate := upper(sIntermediateTable);
  
--  select count(*) into nSanityIndex1 from dba_indexes where table_name = sTableToBuild and owner = sOwner;
--  select count(*) into nSanityIndex2 from dba_indexes where table_name = sIntermediate and owner = sOwner;
  --dbms_output.put_line(nSanityIndex1); dbms_output.put_line(nSanityIndex2);
--  if nSanityIndex1 != nSanityIndex2 then 
--      raise_application_error(-20999,'Index Count Different in Source and Intermediate table. Aborting..!!'); 		
--  end if;

--  select count(*) into nSanityConstraints1 from user_constraints where table_name = sTableToBuild and owner = sOwner;
--  select count(*) into nSanityConstraints2 from user_constraints where table_name = sIntermediate and owner = sOwner;
  --dbms_output.put_line(nSanityConstraints1); dbms_output.put_line(nSanityConstraints2);
--  if nSanityConstraints1 != nSanityConstraints2 then 
--      raise_application_error(-20999,'Constraint Count Different in Source and Intermediate table. Aborting..!!'); 		
--  end if;

  delete from ops$oracle.logbuild where tabowner=sTableOwner and tabname=sTableToBeBuild; 
  sInsert := 'Deleted Old Entries for '|| sTableOwner || '.' || sTableToBeBuild || ' from ops$oracle.logbuild logger..' ;
  iCounter := iCounter+1; LogMsg(sInsert,iCounter);
  commit;
  
  sInsert := 'truncate table ' || sOwner || '.' || sIntermediate ;
  execute immediate sInsert;
  iCounter := iCounter+1; LogMsg(sInsert,iCounter);

  -- Rebuild index of empty intermediate table
--  For rec in (select OWNER, index_name
--		from DBA_indexes
--		where owner = sOwner 
--		and table_name = sIntermediate) 
--  loop
--	iCounter := iCounter+1;    
--  	sInsert := 'Alter index '||  rec.owner || '.' || rec.index_name || ' rebuild ';        
--        execute immediate sInsert;
--  	LogMsg(sInsert,iCounter);
--  end loop;

  dbms_redefinition.can_redef_table( sOwner, sTableToBuild ); iCounter := iCounter+1;
  sInsert := 'Passed Can Redef Validation --> '|| to_char(sysdate,'dd-mon-yy hh24:mi:ss');
  LogMsg(sInsert,iCounter);

  DBMS_REDEFINITION.START_REDEF_TABLE ( sOwner, sTableToBuild, sIntermediate ); iCounter := iCounter+1;
  sInsert := 'Completed Start Redef --> '|| to_char(sysdate,'dd-mon-yy hh24:mi:ss');
  LogMsg(sInsert,iCounter);

  sInsert := 'CREATE UNIQUE INDEX PK_RPER_USERRECORD_INT ON statsdbownr.RPER_USERRECORD_INT(USER_ID, DOMAIN_ID, SUBDOMAIN_ID, KEY) LOCAL STORE IN (HINDEX) Tablespace HINDEX Nologging Online';
--  execute immediate sInsert;

  sInsert := 'CREATE INDEX RPER_USERRECORD_DOM_SUB_INT ON statsdbownr.RPER_USERRECORD_INT(DOMAIN_ID, SUBDOMAIN_ID, KEY, STATE) LOCAL STORE IN (HINDEX) Tablespace HINDEX Nologging Online'; 
--  execute immediate sInsert;

  --sInsert := 'ALTER TABLE statsdbownr.RPER_USERRECORD_INT ADD (CONSTRAINT PK_RPER_USERRECORD_INT PRIMARY KEY (USER_ID, DOMAIN_ID, SUBDOMAIN_ID, KEY) USING INDEX LOCAL)';
 -- execute immediate sInsert;

  DBMS_REDEFINITION.SYNC_INTERIM_TABLE( sOwner, sTableToBuild, sIntermediate ); iCounter := iCounter+1;    
  sInsert := 'Completed Interim sync --> '|| to_char(sysdate,'dd-mon-yy hh24:mi:ss');
  LogMsg(sInsert,iCounter);

  -- Grant Privs to intermediate table
  For rec in (select distinct OWNER, GRANTEE vuser, table_name, PRIVILEGE 
		from DBA_TAB_PRIVS 
		where owner = sOwner 
		and table_name = sTableToBuild) 
  loop
	iCounter := iCounter+1;    
  	sInsert := 'grant '|| rec.PRIVILEGE || ' on '||  rec.owner || '.' || sIntermediate || ' to ' || rec.vuser;
        execute immediate sInsert;
  	LogMsg(sInsert,iCounter);
  end loop;

  DBMS_REDEFINITION.FINISH_REDEF_TABLE( sOwner, sTableToBuild, sIntermediate ); iCounter := iCounter+1; 
  sInsert := 'Completed finish redef --> '|| to_char(sysdate,'dd-mon-yy hh24:mi:ss');
  LogMsg(sInsert,iCounter);
exception
	when others then
		dbms_redefinition.abort_redef_table( sOwner, sTableToBuild, sIntermediate ); 
		raise_application_error(-20999,sqlerrm); 
end;
/

