-- a wrapper for dbms_output.put_line, 
-- it can display line > 255
CREATE OR REPLACE PROCEDURE Show_Message(pmv_Msg_in IN VARCHAR2)
IS
BEGIN
  IF LENGTH(pmv_Msg_in)  > 80 THEN
     DBMS_OUTPUT.Put_Line(SUBSTR(pmv_Msg_in,1,79));
     Show_Message(SUBSTR(pmv_Msg_in,80,LENGTH(pmv_Msg_in)));
  ELSE
     DBMS_OUTPUT.Put_Line(pmv_Msg_in);
  END IF;
EXCEPTION
  WHEN Others THEN
       DBMS_OUTPUT.Disable;
       DBMS_OUTPUT.Enable(1000000);
       Show_Message(SUBSTR(pmv_Msg_in,80,LENGTH(pmv_Msg_in)));
END Show_Message;
/
