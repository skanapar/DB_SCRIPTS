set heading on
set echo off
set feedback on
set pagesize 100
set lines 600
set linesize 200
set verif off
col username for a11
col osuser for a10
col terminal for a8
col program for a32
col machine for a20
col type for a4 trunc
col logon_time hea 'LOGON-START-TIME' for a20
col "DOING?" for a8
col module for a7
col sid for 999
col serial# for 99999
col SidSerial# for a8
clear screen
set timing on
select a.username, a.osuser,a.sid||','||a.serial# SidSerial#,
        --a.terminal,
        substr(a.machine,1,19) machine, substr(a.program,1,30) program,
       --type,
        to_char(a.logon_time,'DD-MON-YYYY HH24:MI:SS') logon_time,
       ltrim(rtrim(substr(b.name,1,7))) "DOING?", substr(a.module,1,7) module
  from v$session a, sys.audit_actions b
 where b.action = a.command
--and a.status ='ACTIVE'
 and username is not null
 and type not like 'BACK%'
 order by username ,osuser, b.name
/

