
set serveroutput on
set termout on
set feedback off
set verify off
column what format a30
column interval format a30
clear buffer
--ACCEPT nextrun date format 'MM/DD/YY HH24:MI' prompt 'Next date/time to run (MM/DD/YY HH:MI): ' 
--alter session set nls_date_format='MM/DD/YY HH24:MI';

declare
jobv integer;
begin
	dbms_job.submit(jobv,'refresh_mv(''FACILITY_READINGS_DELTA_MV'');','&&nextrun','sysdate+(1/144)',TRUE,1,FALSE);
	dbms_job.run(jobv);
	dbms_output.put_line('New job: '||jobv);
end;
/

select job, what, this_date, this_sec, next_date,next_sec, last_date, last_sec, interval, broken, failures from user_jobs
/
