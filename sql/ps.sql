rem like Unix ps command
rem
SET LINE 132 PAGESIZE 1000 FEED OFF;
COLUMN "sid_serial" FORMAT A10
COLUMN "user" FORMAT A10
COLUMN "st" FORMAT A8
COLUMN "schema" FORMAT A10
COLUMN "osuser" FORMAT A10
COLUMN "box" FORMAT A16
COLUMN "prg" FORMAT A30
COLUMN "logon_time" FORMAT A30

SELECT
       ''''
    || sid
    || ','
    || serial#
    || ''';'                       "sid_serial"
     , username                    "user"
     , status                      "st"
     , schemaname                  "schema"
     , osuser                      "osuser"
     , machine                     "box"
     , program                     "prg"
     , TO_CHAR(logon_time, 'DD/MON/YYYY HH24:MI:SS') "logon_time"
  FROM
       v$session
-- WHERE username is not null
-- WHERE
--       program != 'ORACLE80.EXE'
 ORDER BY
       username
/

--SET LINE 120 PAGESIZE 25 FEED ON
