--oem_target_details.sql

select t.host_name
 as     host
 , ip.property_value IP
 , t.target_name
 as     name
 , decode ( t.type_qualifier4
 , ' '
 , 'Normal'
 , t.type_qualifier4 )
 as     type
 , dbv.property_value
 as     version
 , port.property_value port
 , SID.property_value SID
 , logmode.property_value
 as     "Log Mode"
 , oh.property_value
 as     "Oracle Home"
 from mgmt$target t
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'DBVersion' ) dbv
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'Port' ) port
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'SID' ) sid
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'log_archive_mode' ) logmode
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'OracleHome' ) oh
 , ( select tp.target_name
 as     host_name
 , tp.property_value
 from mgmt$target_properties tp
 where tp.target_type = 'host'
 and tp.property_name = 'IP_address' ) ip
 where t.target_guid = port.target_guid
 and port.target_guid = sid.target_guid
 and sid.target_guid = dbv.target_guid
 and dbv.target_guid = logmode.target_guid
 and logmode.target_guid = oh.target_guid
 and t.host_name = ip.host_name
 order by 1, 3;

