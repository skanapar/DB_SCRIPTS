--cpu_hourly_max_per_instance_from_oem.sql
--With the following query, connected to the SYSMAN schema of your EM repository, 
--you can get the hourly max() and/or avg() of user CPU by instance and time.

SELECT entity_name,
  ROUND(collection_time,'HH') AS colltime,
  ROUND(avg_value,2)/16*100   AS avgv, -- 16 is my number of CPU
  ROUND(max_value,2)/16*100   AS maxv  -- same here
FROM gc$metric_values_hourly mv
JOIN em_targets t
ON (t.target_name         =mv.entity_name)
WHERE t.host_name         ='myserver1'  -- myserver1 is the server that has high CPU Usage
AND mv.metric_column_name = 'user_cpu_time_cnt' -- let's get the user cpu time
AND collection_time>sysdate-14  -- for the lase 14 days
ORDER BY entity_name,
  ROUND(collection_time,'HH');

