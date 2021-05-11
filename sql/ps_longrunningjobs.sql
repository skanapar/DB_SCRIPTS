select 
  prcsinstance||'|'||prcsname||'|'||substr(prcstype,1,18)||'|'||
  substr(runcntlid,1,12)||'|'||dbname||'|'||servernamerun||'|'||
  to_char(begindttm,'MM-DD:HH24:MI:SS') as "Job Info",
  substr((60*SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+1,2)
    + SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+4,2)
    + ((SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+7,2)/60))), 1, 5) as ELAPSED_MIN
from
  sysadm.psprcsrqst 
where 
  runstatus = 7 and
  PRCSTYPE <> 'PSJob';


select 
  prcsinstance, prcsname, substr(prcstype,1,18) as prctype,
  substr(runcntlid,1,12) as clientid, dbname, servernamerun, 
  to_char(begindttm,'MM-DD:HH24:MI:SS') as begintime,
  substr((60*SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+1,2)
    + SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+4,2)
    + ((SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+7,2)/60))), 1, 5) as ELAPSED_MIN
from
  sysadm.psprcsrqst 
where 
  runstatus = 7 and
  PRCSTYPE <> 'PSJob';