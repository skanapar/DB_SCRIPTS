set lines 80
set feedback off
set verif off
set head off
set term off
set pages 0
col line1 format A75
col line2 format A75
set timing off
set time off
select to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') START_TIME From dual;
spool /home/oracle/SQL/trcstart.sql
select 'oradebug setospid '||spid line1,
       'oradebug EVENT 10046 trace name context forever, level 12' Line2
   from v$session a, sys.audit_actions b,v$process p
where b.action = a.command
 and a.username = 'USERSERVER'
 and a.machine = 'userbesl01.pogo.abn-iad.ea.com'
 and p.addr = a.paddr
 and rownum<2
/
spool off
set term on
