set line 125
set trimout on
set pages 0
column description format a30
column "Street Number" format a10
column "Street Name" format a40
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
spool stoppages
select 
-- requestid, a.description, 
b.workorderid, b.description, b.initiatedate,
substr(probaddress,1,instr(probaddress,' ')-1) "Street Number",
substr(probaddress,instr(probaddress,' ')+1) "Street Name"
from request a, workorder b
where
a.workorderid = b.workorderid
and wotemplateid in (1117, 1118, 1119, 1136, 1175, 1200, 1099, 1137, 5292, 5293, 5294, 5303, 1215,
	1216, 3630, 5275, 5281, 5282, 5283, 5287, 5288, 5289, 5290, 5291, 1217, 5278, 5279, 5280)
and b.initiatedate >= '01-Jan-2002'
and to_number(b.workorderid) > 10200000
and b.datecancelled is null
and a.datecancelled is null
order by b.initiatedate, b.workorderid
/
spool off
