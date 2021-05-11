-- CPU Utilization %
WITH base AS (	
	SELECT
      entity_type ,
      SUBSTR(entity_name, 1, 4) AS database_machine ,
      entity_name               AS host_name ,
      metric_column_label ,
      metric_column_name ,
      metric_group_label ,
      collection_time ,
      TO_CHAR(collection_time,'yyyy')
      || '-Q'
      || TO_CHAR(collection_time,'q') AS year_quarter ,
      extract(YEAR FROM collection_time)
      ||'-'
      || ltrim(TO_CHAR(extract(MONTH FROM collection_time),'09')) AS year_month
      ,
      TO_CHAR(collection_time,'yyyy-ww') AS year_week ,
      collection_time                    AS year_month_day ,
      ROUND(avg_value,2)                 AS avg_value ,
      max_value ,
      stddev_value
    FROM
      sysman.gc$metric_values_daily
    WHERE
      entity_type          = 'host'
    AND metric_column_name = 'cpuUtil'
    AND metric_group_label = 'Load' )
SELECT *
  FROM base;
    
-- Memory Utilization

	base AS
  (
    SELECT
      entity_type,
      substr(1,4,entity_name)         AS database_machine, -- you may need to change this
      entity_name          AS host_name,
      ROUND (b.mem / 1024) AS memory_size_gb,
      metric_column_label,
      metric_column_name,
      metric_group_label,
      collection_time,
      TO_CHAR (collection_time, 'yyyy')
      || '-Q'
      || TO_CHAR (collection_time, 'q') AS year_quarter,
      EXTRACT (YEAR FROM collection_time)
      || '-'
      || LTRIM ( TO_CHAR (EXTRACT (MONTH FROM collection_time), '09')) AS
      year_month,
      TO_CHAR (collection_time, 'yyyy-ww')    AS year_week,
      TO_CHAR (collection_time, 'yyyy-mm-dd') AS year_month_day,
      ROUND (avg_value)                       AS avg_value,
      max_value
    FROM
      sysman.gc$metric_values_daily a,
      sysman.mgmt$os_hw_summary b,
    WHERE
      a.entity_name         = b.host_name
    AND c.host_name         = REPLACE(a.entity_name, '.autozone.com')
    AND metric_column_name IN ('usedLogicalMemoryPct', 'logicMemfreePct')
    AND metric_group_label  = 'Load'
  )
  ,
  base_point_one AS
  (
    SELECT
      *
    FROM
      (
        SELECT
          database_machine,
          host_name,
          memory_size_gb,
          metric_column_name,
          collection_time,
          year_quarter,
          year_month,
          year_week,
          year_month_day,
          max_value
        FROM
          base
      )
      PIVOT (MAX (max_value) FOR metric_column_name IN ('logicMemfreePct' AS
      max_free_memory_pct, 'usedLogicalMemoryPct'                         AS
      max_used_memory_pct))
  )
  ,
  base_point_two AS
  (
    SELECT
      *
    FROM
      (
        SELECT
          database_machine,
          host_name,
          memory_size_gb,
          metric_column_name,
          collection_time,
          year_quarter,
          year_month,
          year_week,
          year_month_day,
          avg_value
        FROM
          base
      )
      PIVOT (MAX (avg_value) FOR metric_column_name IN ('logicMemfreePct' AS
      avg_free_memory_pct, 'usedLogicalMemoryPct'                         AS
      avg_used_memory_pct))
  )
  ,
  base_point_three AS
  (
    SELECT
      *
    FROM
      (
        SELECT
          a.host_name,
          ROUND ( SUM (mem / 1024) OVER (PARTITION BY cluster_name) ) AS
          total_memory_size_gb
        FROM
          sysman.mgmt$os_hw_summary a,
          clusters c
        WHERE
          REPLACE(a.host_name, '.autozone.com') = c.host_name
      )
  )
SELECT 
  *
FROM
  base_point_one a,
  base_point_two b,
  base_point_three c
WHERE
  a.host_name         = b.host_name
AND a.collection_time = b.collection_time
AND a.host_name       = c.host_name; 
    
-- Storage ASM

  SELECT
      a.entity_type,
      a.metric_group_label,
      a.metric_column_name,
      a.metric_column_label,
      --c.cluster_name                   AS database_machine,
      REPLACE (a.entity_name, '+', '') AS asm,
      a.collection_time,
      a.key_part_1              AS diskgroup_name,
      a.key_part_2              AS database_name,
      ROUND (a.max_value        /1024) AS max_value,
      ROUND ( SUM ( a.max_value / 1024) over ( partition BY metric_column_name,
      a.entity_name, collection_time)) AS total_usable_per_metric_gb,
      TO_CHAR (collection_time, 'yyyy')
      || '-Q'
      || TO_CHAR (collection_time, 'q') AS year_quarter,
      EXTRACT (YEAR FROM collection_time)
      || '-'
      || LTRIM ( TO_CHAR (EXTRACT (MONTH FROM collection_time), '09')) AS
      year_month,
      TO_CHAR (collection_time, 'yyyy-ww')    AS year_week,
      TO_CHAR (collection_time, 'yyyy-mm-dd') AS year_month_day
    FROM
      sysman.gc$metric_values_daily a,
      mgmt$manageable_entities d
    WHERE
      a.entity_guid = d.entity_guid
    --AND c.host_name = d.host_name -- You may need a REPLACE function here to map host names.
  ) -- ASM (Actual) Allocated Usable Total
  -- Calculate Actual Used GB and Actual Used %
  ,
  base_two AS
  (
    SELECT
      --database_machine,
      asm,
      collection_time,
      year_quarter,
      year_month,
      year_week,
      year_month_day,
      usable_free_gb,
      usable_total_gb - usable_free_gb AS usable_used_gb,
      usable_total_gb,
      ROUND ( (100 - ( (usable_free_gb / usable_total_gb) * 100)), 2) AS
      used_percent
    FROM
      ( -- Convert rows to columns using PIVOT
        SELECT DISTINCT
          metric_column_name,
          --database_machine,
          asm,
          collection_time,
          year_quarter,
          year_month,
          year_week,
          year_month_day,
          total_usable_per_metric_gb
        FROM
          base
        WHERE
          entity_type           = 'osm_cluster'
        AND metric_group_label  = 'Disk Group Usage'
        AND metric_column_name IN ('usable_file_mb', 'usable_total_mb') 
      )
      PIVOT (SUM ( total_usable_per_metric_gb) FOR metric_column_name IN (
      'usable_file_mb' AS usable_free_gb, 'usable_total_mb' AS usable_total_gb)
      )
  )
SELECT *
  FROM base_two;