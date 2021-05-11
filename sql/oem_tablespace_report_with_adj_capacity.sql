--oem_tablespace_report_with_adj_capacity.sql
--This script is run against the OEM repository and reports
--tablespaces that have a particular capacity or higher full


WITH qb_ts_max_sizes AS (
     SELECT 
          target_guid
          , tablespace_name
          , collection_timestamp 
          , ROUND( sum( max_file_size ) /1048576, 2 ) as tbs_autox_total
     FROM sysman.mgmt$db_datafiles 
     GROUP BY target_guid, tablespace_name, collection_timestamp
), qb_db_targets AS (
     SELECT host_name, target_guid FROM sysman.mgmt$target WHERE ( target_type='rac_database' OR ( target_type='oracle_database' AND type_qualifier3 != 'RACINST')) 
), qb_db_tablespaces as (
     SELECT target_guid, tablespace_name, status from sysman.mgmt$db_tablespaces
), qb_db_properties AS (
     SELECT 
          target_guid
          , MAX( CASE WHEN prop.property_name = 'orcl_gtp_contact' THEN prop.property_value END ) contact
          , MAX( CASE WHEN prop.property_name = 'orcl_gtp_lifecycle_status' THEN prop.property_value END ) lifecycle
     FROM sysman.mgmt$target_properties prop
     GROUP BY target_guid 
) 
SELECT 
     host_name
     , main.target_name as db_name
     , key_value as tablespace_name
     , ROUND( tbs_used / tbs_allocated * 100, 2 ) as "TBS_REPORTED_USED_PERCENT"
     , ROUND( tbs_used / tbs_autox_total * 100, 2 ) as "TBS_AUTOX_USED_PERCENT"
     , prop.contact
     , collection_timestamp
FROM (
     SELECT 
          tgt.host_name
          , tgt.target_guid
          , mc.target_name
          , mc.key_value
          , TO_NUMBER( MAX( CASE WHEN mc.metric_column = 'spaceAllocated' THEN mc.value END ) ) AS tbs_allocated
          , TO_NUMBER( MAX( CASE WHEN mc.metric_column = 'spaceUsed' THEN mc.value END )  ) AS tbs_used
          , max( mc.collection_timestamp ) last_collected
     FROM sysman.mgmt$metric_current mc, qb_db_targets tgt
     WHERE mc.metric_name = 'tbspAllocation' 
     AND mc.target_guid = tgt.target_guid
     AND mc.value > 0 
     GROUP BY tgt.host_name, tgt.target_guid, mc.target_name, mc.key_value
) main, qb_ts_max_sizes tsmax, qb_db_tablespaces tsro, qb_db_properties prop
WHERE main.target_guid = tsmax.target_guid
AND main.key_value = tsmax.tablespace_name
AND main.target_guid = tsro.target_guid
AND main.key_value = tsro.tablespace_name
AND main.target_guid = prop.target_guid
AND tsro.status != 'READ ONLY'
AND ROUND( main.tbs_used / main.tbs_allocated * 100, 2 ) >= 80 
AND ROUND( main.tbs_used / tsmax.tbs_autox_total * 100, 2 ) between 90 AND 100
--     AND prop.lifecycle IN ('MissionCritical','Production')
ORDER BY 1, 2 ;
