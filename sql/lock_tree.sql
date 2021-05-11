SET LINESIZE 600
SET PAGESIZE 1000

COLUMN "session tree" FORMAT A25
COLUMN "OBJ Locked" FORMAT A25
COLUMN machine FORMAT A20
COLUMN osuser FORMAT A10
COLUMN module FORMAT A10
COLUMN program FORMAT A15
COLUMN event FORMAT A30
COLUMN logon_time FORMAT A20
COLUMN curr_sql FORMAT A40
COLUMN prev_sql FORMAT A40

SELECT 
	LPAD(' ', (level-1)*2, ' ') || 
	s.username || '(' ||
	s.sid||','||s.serial#||')' AS "session tree",
--   s.osuser,
    s.lockwait,
    s.status,
--   s.module,
    s.machine,
--    s.program,
	s.seconds_in_wait "wait secs",
	s.event,
	   (select object_type||' '||owner||'.'||object_name 
	   from dba_objects where object_id=s.row_wait_obj#) as "OBJ Locked",
       to_char(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') as logon_time,
	   (select rtrim(sql_text) from v$sqlarea 
	   where sql_id=s.sql_id and address=s.sql_address) as curr_sql,
	   (select rtrim(sql_text) from v$sqlarea 
	   where sql_id=s.prev_sql_id and address=s.prev_sql_addr) as prev_sql
FROM   v$session s
WHERE TYPE<>'BACKGROUND'
 AND ( level > 1 or ( level = 1 and s.sid in (select blocking_session from v$session)))
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL
;

