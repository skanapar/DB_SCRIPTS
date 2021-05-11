create or replace
FUNCTION replaceClob (
srcClob IN CLOB,
replaceStr IN VARCHAR2,
replaceWith IN VARCHAR2)
RETURN CLOB
IS

vBuffer    VARCHAR2 (32767);
l_amount   BINARY_INTEGER := 32767;
l_pos      PLS_INTEGER := 1;
l_clob_len PLS_INTEGER;
newClob    CLOB := EMPTY_CLOB;
   
BEGIN
  -- initalize the new clob
  dbms_lob.createtemporary(newClob,TRUE);
   
  l_clob_len := dbms_lob.getlength(srcClob);

  WHILE l_pos < l_clob_len
  LOOP
    dbms_lob.read(srcClob, l_amount, l_pos, vBuffer);

    IF vBuffer IS NOT NULL THEN
      -- replace the text
      vBuffer := replace(vBuffer, replaceStr, replaceWith);
      -- write it to the new clob
      dbms_lob.writeappend(newClob, LENGTH(vBuffer), vBuffer);
    END IF;
    l_pos := l_pos + l_amount;
  END LOOP;
   
  RETURN newClob;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/
