--oem_targets_with_tns_listeners.sql

List Targets with TNS Listener ports configured :

SELECT mgmt$target.host_name
 , mgmt$target.target_name
 , mgmt$target.target_type
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 and ( mgmt$target.target_type = 'oracle_listener' )
 and ( mgmt$target_properties.property_name = 'Port' );
 