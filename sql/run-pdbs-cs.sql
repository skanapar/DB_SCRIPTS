COL report_date NEW_V report_date;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24-MI-SS') report_date FROM DUAL;
SPO /tmp/run-pdbs-cs_&&report_date..txt;
 
accept sql_cmd prompt "Enter SQL to run in all PDBs: "

VAR v_cursor CLOB;
BEGIN
  :v_cursor := q'[
&&sql_cmd
  ]';
END;
/
PRINT v_cursor;
 
SET SERVEROUTPUT ON
DECLARE
  l_cursor_id INTEGER;
  l_rows_processed INTEGER;
BEGIN
  l_cursor_id := DBMS_SQL.OPEN_CURSOR;
  FOR i IN (SELECT name
              FROM v$containers 
             WHERE con_id > 2 
               AND open_mode = 'READ WRITE'
             ORDER BY 1)
  LOOP
    DBMS_OUTPUT.PUT_LINE('PDB:'||i.name); 
    DBMS_SQL.PARSE
      ( c             => l_cursor_id
      , statement     => :v_cursor
      , language_flag => DBMS_SQL.NATIVE
      , container     => i.name
      );
      l_rows_processed := DBMS_SQL.EXECUTE(c => l_cursor_id);
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(c => l_cursor_id);
END;
/
 
SPO OFF;
