--oem_database_inventory.sql

SELECT DISTINCT
             tbl_tar.target_guid,
             tbl_sid.sid AS instance_name,
             CASE
                WHEN tbl_tar.host_name LIKE '%.%'
                THEN
                   LOWER (SUBSTR (tbl_tar.host_name,
                                  1,
                                    INSTR (tbl_tar.host_name,
                                           '.',
                                           2,
                                           1)
                                  - 1))
                ELSE
                   tbl_tar.host_name
             END
                host_name,
             tbl_ver.version,
             CASE
                WHEN tbl_mem.mem_max > 0
                THEN
                   CEIL (tbl_mem.mem_max / 1024 / 1024)
                ELSE
                   CEIL (tbl_sga.sga / 1024 / 1024 + tbl_pga.pga / 1024 / 1024)
             END
                total_memory,
             tbl_dg.data_guard_status,
             tbl_port.port,
             tbl_home.PATH
        FROM (SELECT p.target_guid, p.property_value AS port
                FROM mgmt_target_properties p
               WHERE p.property_name = 'Port') tbl_port,
             (SELECT s.target_guid, UPPER (s.property_value) AS sid
                FROM mgmt_target_properties s
               WHERE s.property_name = 'SID') tbl_sid,
             (SELECT s.target_guid, s.property_value AS version
                FROM mgmt_target_properties s
               WHERE s.property_name IN ('Version')) tbl_ver,
             (SELECT s.target_guid, s.property_value AS PATH
                FROM mgmt_target_properties s
               WHERE s.property_name IN ('OracleHome')) tbl_home,
             (SELECT s.target_guid, s.property_value AS data_guard_status
                FROM mgmt_target_properties s
               WHERE s.property_name IN ('DataGuardStatus')) tbl_dg,
             (SELECT s.target_guid, s.VALUE AS PGA
                FROM mgmt$db_init_params s
               WHERE s.name = 'pga_aggregate_target') tbl_pga,
             (SELECT s.target_guid, s.VALUE AS SGA
                FROM mgmt$db_init_params s
               WHERE s.name = 'sga_max_size') tbl_sga,
             (SELECT s.target_guid, s.VALUE AS mem_max
                FROM mgmt$db_init_params s
               WHERE s.name = 'memory_target') tbl_mem,
             mgmt_target_properties tbl_main,
             mgmt_targets tbl_tar
       WHERE     tbl_main.target_guid = tbl_port.target_guid(+)
             AND tbl_main.target_guid = tbl_sid.target_guid(+)
             AND tbl_main.target_guid = tbl_tar.target_guid(+)
             AND tbl_main.target_guid = tbl_ver.target_guid(+)
             AND tbl_main.target_guid = tbl_home.target_guid(+)
             AND tbl_main.target_guid = tbl_dg.target_guid(+)
             AND tbl_main.target_guid = tbl_pga.target_guid(+)
             AND tbl_main.target_guid = tbl_sga.target_guid(+)
             AND tbl_main.target_guid = tbl_mem.target_guid(+)
             AND tbl_tar.target_type in('oracle_database','rac_database')
    GROUP BY tbl_tar.target_guid,
             tbl_port.port,
             tbl_sid.sid,
             tbl_tar.host_name,
             tbl_ver.version,
             tbl_home.PATH,
             tbl_dg.data_guard_status,
             tbl_pga.pga,
             tbl_sga.sga,
             tbl_mem.mem_max
    ORDER BY 2;
