select owner, object_type, count(*) from dba_objects 
where 
owner in ('SOA01_SOAINFRA')
--and object_type<>'SYNONYM'
group by owner, object_type
order by owner,object_type
/
