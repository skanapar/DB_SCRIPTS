--oem_target_init_parameters.sql
--Note - you need to change the target type to report on the desired target (RAC is default)

SELECT   target_name,
           target_type,
           name,
           VALUE
    FROM   MGMT$ECM_VISIBLE_SNAPSHOTS A, SYSMAN.MGMT_DB_INIT_PARAMS_ECM B
   WHERE       A.ECM_SNAPSHOT_ID = B.ECM_SNAPSHOT_ID
              AND TARGET_TYPE = 'rac_database'  -- Choose TARGET_TYPE
           AND name LIKE 'remote_listener%'     -- Look for a relevant Parameter
GROUP BY   target_name,
           target_type,
           name,
           VALUE
ORDER BY   Target_name, name ;