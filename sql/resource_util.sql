SELECT rl.resource_name, rl.current_utilization, rl.max_utilization,
rl.limit_value
FROM v$resource_limit rl
WHERE upper(rl.resource_name) IN ('SESSIONS',
                                  'PROCESSES',
                                  'TRANSACTIONS',
                                  'DML_LOCKS',
                                  'ENQUEUE_LOCKS',
                                  'ENQUEUE_RESOURCES',
                                  'DISTRIBUTED_TRANSACTIONS')
ORDER BY rl.resource_name
/
