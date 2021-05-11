--
-- kill_sessions.sql
-- Create as SYS, exec immediate does not work under another dba account
--
CREATE OR REPLACE PROCEDURE kill_sniped_sessions
 IS 
  stmt_str  VARCHAR(400); 
  sid_v   VARCHAR(30); 
  serial#_v  VARCHAR(30); 
  username_v  VARCHAR(40); 
  CURSOR pri IS 
    SELECT sid, serial#, username 
    FROM sys.v_$session 
    WHERE 
      username IS NOT NULL 
      AND type <> 'BACKGROUND' 
      AND status = 'SNIPED'; 
  usr pri%ROWTYPE; 
BEGIN 
 FOR usr IN pri 
  LOOP 
   sid_v  := usr.sid; 
   serial#_v := usr.serial#; 
   stmt_str := 'ALTER SYSTEM KILL SESSION ''' || sid_v || ',' || serial#_v || ''' IMMEDIATE'; 
   EXECUTE IMMEDIATE(stmt_str); 
  END LOOP; 
END;
