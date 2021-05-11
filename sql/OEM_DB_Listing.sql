select * from (SELECT DISTINCT
       t.display_name ciname,
       p1.property_value version,
       type_qualifier1 engine_edition,
       DECODE (t.target_type,
               'rac_database', 'RAC',
               'oracle_database', 'Stand Alone',
               t.target_type)
           multi_instance,
       DECODE (type_qualifier2, '2', NULL, type_qualifier2) instance_role,
       p2.property_value edition,
       t.target_guid
  --*
  FROM sysman.mgmt$group_derived_memberships o,
       sysman.mgmt$target t,
       (SELECT *
          FROM sysman.mgmt$target_properties
         WHERE property_name IN ('Version')) p1,
       (SELECT *
          FROM sysman.mgmt$target_properties
         WHERE property_name IN ('VersionBanner')) p2
 WHERE     o.member_target_type IN ('oracle_database', 'rac_database')
       AND (   t.target_type = 'rac_database'
            OR (    t.target_type = 'oracle_database'
                AND t.type_qualifier3 != 'RACINST'))
       AND o.member_target_guid = t.target_guid
       AND p1.target_guid(+) = t.target_guid
       AND p2.target_guid(+) = t.target_guid)
       --where instance_role != 'Physical Standby'