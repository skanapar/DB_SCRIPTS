SET SERVEROUTPUT ON
SET LINESIZE 200
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

spool audit_obj_stmts.sql

DECLARE

    CURSOR cu_ao IS
        SELECT *
        FROM   dba_obj_audit_opts a
        ORDER BY a.object_name;
    
    TYPE rec_ty is RECORD (optn varchar2(10), opts varchar2(100));    
    TYPE varray_ty is VARRAY(20) of rec_ty;
    my_varray varray_ty := varray_ty();
	
	FUNCTION str_trans ( p_str IN VARCHAR2 )
		RETURN VARCHAR2 IS
		BEGIN
			CASE
				WHEN p_str = 'S/-' THEN 
					RETURN ' WHENEVER SUCCESSFUL BY SESSION;';
				WHEN p_str = '-/S' THEN 
					RETURN ' WHENEVER UNSUCCESSFUL BY SESSION;';
				WHEN p_str = 'A/-' THEN 
					RETURN ' WHENEVER SUCCESSFUL BY ACCESS;';
				WHEN p_str = '-/A' THEN 
					RETURN ' WHENEVER UNSUCCESSFUL BY ACCESS;';
				WHEN p_str = 'S/S' THEN 
					RETURN ' BY SESSION;';
				WHEN p_str = 'A/A' THEN 
					RETURN ' BY ACCESS;';
				WHEN p_str = 'S/A' THEN 
					RETURN ' WHENEVER SUCCESSFUL BY SESSION WHENEVER UNSUCCESSFUL BY ACCESS;';
				WHEN p_str = 'A/S' 
					THEN RETURN ' WHENEVER SUCCESSFUL BY ACCESS WHENEVER UNSUCCESSFUL BY SESSION;';
				ELSE RETURN NULL;
			END CASE;
		END;
		
BEGIN

    DBMS_Output.Disable;
    DBMS_Output.Enable(1000000);
    
	FOR i IN 1 .. 20 LOOP
		my_varray.extend;
	END LOOP;
	
    FOR cur_rec IN cu_ao LOOP
    	my_varray(1).optn := 'ALTER';
    	my_varray(1).opts := str_trans(cur_rec.ALT);
    	my_varray(2).optn := 'AUDIT';
    	my_varray(2).opts := str_trans(cur_rec.AUD);
    	my_varray(3).optn := 'COMMENT';
    	my_varray(3).opts := str_trans(cur_rec.COM);
    	my_varray(4).optn := 'DELETE';
    	my_varray(4).opts := str_trans(cur_rec.DEL);
    	my_varray(5).optn := 'GRANT';
    	my_varray(5).opts := str_trans(cur_rec.GRA);
    	my_varray(6).optn := 'INDEX';
    	my_varray(6).opts := str_trans(cur_rec.IND);
    	my_varray(7).optn := 'INSERT';
    	my_varray(7).opts := str_trans(cur_rec.INS);
    	my_varray(8).optn := 'LOCK';
    	my_varray(8).opts := str_trans(cur_rec.LOC);
    	my_varray(9).optn := 'RENAME';
    	my_varray(9).opts := str_trans(cur_rec.REN);
    	my_varray(10).optn := 'SELECT';
    	my_varray(10).opts := str_trans(cur_rec.SEL);
    	my_varray(11).optn := 'UPDATE';
    	my_varray(11).opts := str_trans(cur_rec.UPD);
    	my_varray(12).optn := 'EXECUTE';
    	my_varray(12).opts := str_trans(cur_rec.EXE);
    	my_varray(13).optn := 'CREATE';
    	my_varray(13).opts := str_trans(cur_rec.CRE);
    	my_varray(14).optn := 'READ';
    	my_varray(14).opts := str_trans(cur_rec.REA);
    	my_varray(15).optn := 'WRITE';
    	my_varray(15).opts := str_trans(cur_rec.WRI);
    	my_varray(16).optn := 'FLASHBACK';
    	my_varray(16).opts := str_trans(cur_rec.FBK);
    	
    	FOR i in 1 .. 16 LOOP
    		IF my_varray(i).opts IS NOT NULL THEN
    			DBMS_Output.Put_Line('AUDIT '||my_varray(i).optn||' ON '||cur_rec.owner||'.'||cur_rec.object_name||my_varray(i).opts);
    		END IF;
        END LOOP;
        	
    END LOOP;

END;
/

spool off

PROMPT
SET VERIFY ON

           