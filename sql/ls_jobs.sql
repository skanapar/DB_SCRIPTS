set linesize 200
col job for 9999
col log_user for a13
col what for a45
col Next for a23
col Last for a23
col BROKEN for a5
col FAILURES for 99999
set pagesize 20

select  job, log_user,
        what,to_char(next_date,'dd-mon-yyyy hh24:mi:ss') Next,
        to_char(LAST_DATE,'dd-mon-yyyy hh24:mi:ss') Last,
        BROKEN,
        FAILURES
from dba_jobs;
