select t.host_name as host, SID.property_value SID, t.target_name as name, 
decode(t.type_qualifier4,' ','No Standby',t.type_qualifier4) as INSTANCE_ROLE, 
dbv.property_value as version , type_qualifier1 engine_edition,  oh.property_value as "Oracle Home", t.target_guid
from mgmt$target t , 
( select p.target_guid, p.property_value from mgmt$target_properties p where p.property_name='DBVersion') dbv,
( select p.target_guid, p.property_value from mgmt$target_properties p where p.property_name='SID') sid,
( select p.target_guid, p.property_value from mgmt$target_properties p where p.property_name='log_archive_mode') logmode,
( select p.target_guid, p.property_value from mgmt$target_properties p where p.property_name='OracleHome') oh,
(select tp.target_name as host_name, tp.property_value from mgmt$target_properties tp where tp.target_type='host' and tp.property_name='IP_address') ip
where t.target_guid=sid.target_guid
and sid.target_guid=dbv.target_guid
and dbv.target_guid=logmode.target_guid
and logmode.target_guid=oh.target_guid
and t.host_name=ip.host_name
order by 1,2