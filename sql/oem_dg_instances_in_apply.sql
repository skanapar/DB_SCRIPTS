--oem_dg_instances_in_apply.sql
--List Dataguard Instances mounted in APPLY mode

SELECT mgmt$target.host_name
 , mgmt$target.target_name
 , mgmt$target.target_type
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 and ( mgmt$target.target_type = 'oracle_database' )
 and ( mgmt$target_properties.property_name = 'OpenMode' )
 and PROPERTY_VALUE like 'READ%ONLY%WITH%APPLY%';
