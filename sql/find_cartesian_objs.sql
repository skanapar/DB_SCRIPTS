select distinct object_owner, object_name from v$sql_plan
where sql_id in (select sql_id from v$sql_plan where upper(options) like '%CARTESIAN%')
and object_owner not in ('SYS','SYSTEM','DBSNMP')
/
