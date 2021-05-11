set linesize 200 pages 1000 termout off feedback off long 2000
column INSTANCE_NAME format a8
column executions format 9999999999
column LastCallSec format 9999999999
column Program format a15
column SID format 999
column serial# format 9999999
column SPID format 9999999
column OSUSER format a8
column Client_info format a20
column sql_id format a15 
column plan_hash_value format 9999999999 
column SQL_TXT format a85 
column prcstype a20 
column runcntlid a15 
column oprid a22 

--SET MARKUP HTML ON spool on
spool ${LOGFILE_JOBS}
select prcsinstance, prcsname, substr(prcstype,1,18) PRCSTYPE, substr(runcntlid,1,12) RUNCNTLID, dbname, servernamerun, oprid,
to_char(begindttm,'MM-DD:HH24:MI:SS') as START_TIME, substr((60*SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+1,
2) +
		SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+4,2)
		+ ((SUBSTR((sysdate-begindttm), INSTR((sysdate-begindttm),' ')+7,2)/60)
)), 1, 5) as ELAPSED_MIN
from sysadm.psprcsrqst where runstatus = 7  and begindttm < sysdate-(1/24)
and PRCSTYPE <> 'PSJob';

SPOOL OFF

EXIT;


