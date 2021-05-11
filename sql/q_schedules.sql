select schema,qname,destination, start_date, start_time, latency, schedule_disabled, process_name,
last_run_date, last_run_time, total_number  from dba_queue_schedules
where qname='TOCERT_Q' and schema='EVERETT'