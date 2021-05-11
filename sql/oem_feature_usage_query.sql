select host, database_name, instance_name, target_type, name,  currently_used, detected_usages, first_usage_date, last_usage_date
from sysman.mgmt$db_featureusage
where name like 'Database Replay%'
and first_usage_date is not null
order by instance_name;

