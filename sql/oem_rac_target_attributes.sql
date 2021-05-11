--oem_rac_target_attributes.sql
--List RAC databases and their Attributes like ClusterName, Dataguard Status.
--Change "property_name" attribute per your need

SELECT mgmt$target.host_name
 , mgmt$target.target_name
 , mgmt$target.target_type
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 and ( mgmt$target.target_type = 'rac_database' )
 and ( mgmt$target_properties.property_name in ( 'RACOption'
 , 'DBName'
 , 'DBDomain'
 , 'DBVersion'
 , 'ClusterName'
 , 'DataGuardStatus'
 , 'MachineName'
 , 'Role'
 , 'SID' ) )
 order by mgmt$target.host_name, mgmt$target.target_name,
mgmt$target_properties.property_name;  

