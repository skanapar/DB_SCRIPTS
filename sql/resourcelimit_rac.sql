define OUTF = &1
define PERCENT = &2 
set verify   off
set feedback off
set heading  off
set lines 132
set pagesize 100
spool &OUTF
set serveroutput on size 100000
set trimspool on

DECLARE

PCT NUMBER;                   /* The percentage that if the resource has used - send message */ 
vCpercent NUMBER;                    /* The calculated percentage the resource is actually using    */ 
CURSOR cGetRs(iID number) IS SELECT INST_ID,RESOURCE_NAME,CURRENT_UTILIZATION,MAX_UTILIZATION,INITIAL_ALLOCATION,LIMIT_VALUE
	FROM gv$resource_limit WHERE LIMIT_VALUE not like '%UNLIMITED%' and INST_ID=iID;
rec1 cGetRs%ROWTYPE;
i INT;
vInstances INT;
iAMM INT;

BEGIN

PCT:=&PERCENT;
  /* Check number of RAC instances */
select max(INST_ID) into vInstances from gv$database;
FOR i in 1..vInstances LOOP

	/* Check if using ASMM */
	iAMM:=0;
	select decode(value,0,1,0) into iAMM from gv$parameter where inst_id=i and name='sga_target';

	OPEN cGetRs(i);
	LOOP
		FETCH cGetRs INTO rec1;
		EXIT WHEN cGetRs%NOTFOUND;
		
		/* Calculate percentage used  for this resource */
		vCpercent:=(rec1.MAX_UTILIZATION/to_number(rec1.LIMIT_VALUE))*100;

		/* lines for debugging --
		DBMS_OUTPUT.PUT_LINE('% = '||PCT||' '||vCpercent);
		*/

		/* Only print out if % > to given % value */
		IF vCpercent > PCT THEN

			/* and disregard when gcs_% resources are above the threshold when AMM is being used */
			IF not ( rec1.resource_name like 'gcs_%' and iAMM=1 ) THEN
				DBMS_OUTPUT.PUT_LINE('INSTANCE ID =      '||rec1.inst_id);
				DBMS_OUTPUT.PUT_LINE('RESOURCE NAME =    '||rec1.resource_name); 
				DBMS_OUTPUT.PUT_LINE('CURRENT =          '||rec1.CURRENT_UTILIZATION); 
				DBMS_OUTPUT.PUT_LINE('MAX UTILIZATION =  '||rec1.MAX_UTILIZATION); 
				DBMS_OUTPUT.PUT_LINE('LIMIT VALUE =      '||to_number(rec1.LIMIT_VALUE)); 
				DBMS_OUTPUT.PUT_LINE('% USED THRESHOLD = '||PCT); 
				DBMS_OUTPUT.PUT_LINE('% ACTUAL USED =    '||round(vCpercent,2)||'%'); 
				DBMS_OUTPUT.PUT_LINE('==========================='); 
				
			END IF;
		END IF;
	END LOOP;
	CLOSE cGetRs;
END LOOP;

END;
/

spool off
exit
