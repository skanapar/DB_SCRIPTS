CREATE OR REPLACE PROCEDURE all_pdb_exec(cmd VARCHAR2)
IS
    err_occ            BOOLEAN;
    curr_pdb           VARCHAR2(30);
    pdb_name           VARCHAR2(30);
    cmd_out            VARCHAR2(4000);

    cursor sel_pdbs IS SELECT NAME FROM V$CONTAINERS
                       WHERE NAME <> 'PDB$SEED' order by con_id desc;
  BEGIN
 
    -- Store the original PDB name
    SELECT sys_context('userenv', 'con_name') INTO curr_pdb FROM DUAL;
    IF curr_pdb <> 'CDB$ROOT' THEN
      dbms_output.put_line('Operation valid in ROOT only');
    END IF;
 
    err_occ := FALSE;
    dbms_output.put_line('---');
    dbms_output.put_line('PDB_NAME                       ');
    dbms_output.put_line('-------------------------------');
    dbms_output.put_line(cmd||' Output:');
    dbms_output.put_line('--------------------------------------------------------------------------------');

    FOR pdbinfo IN sel_pdbs LOOP
 
      pdb_name := DBMS_ASSERT.ENQUOTE_NAME(pdbinfo.name, FALSE);
      EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = ' || pdb_name;
 
      BEGIN
        pdb_name := rpad(substr(pdb_name,1,30), 30, ' ');
        dbms_output.put_line(pdb_name);
        EXECUTE IMMEDIATE cmd into cmd_out;
        cmd_out := rpad(substr(cmd_out,1,80), 80, ' ');
        dbms_output.put_line(cmd_out);
        dbms_output.put_line('--------------------------------------------------------------------------------');
 
      EXCEPTION
        WHEN OTHERS THEN
        err_occ := TRUE;
      END;
    END LOOP;
 
    IF err_occ = TRUE THEN
       dbms_output.put_line('One or more PDB resulted in an error');
    END IF;
  END;
.
/
set serveroutput on
accept sql_cmd prompt "Single row single value SQL: "
exec all_pdb_exec('&&sql_cmd');

