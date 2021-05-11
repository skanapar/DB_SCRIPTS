COLUMN name  FORMAT A40
COLUMN value FORMAT A40

SELECT name,
       value
FROM   v$parameter
WHERE  
--SUBSTR(name, 1, 1) = '_'
name in ('sga_target', 'sga_max_size','shared_pool_size','shared_pool_reserved_size','large_pool_size','db_cache_size','pga_aggregate_target')
ORDER BY name;

COLUMN FORMAT DEFAULT
