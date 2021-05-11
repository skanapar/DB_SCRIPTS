--oem_targets_cpu_version_for_licensing.sql
--List Machine_Names, CPU Count & Database Verion for Licensing

SELECT mgmt$target.host_name
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 AND ( mgmt$target_properties.property_name in ( 'CPUCount','DBVersion' ) )
 GROUP BY mgmt$target.host_name
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 order by mgmt$target.host_name;
