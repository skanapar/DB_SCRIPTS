select * from v$parameter where name ='resource_limit'
/
break on profile nodup
select PROFILE, RESOURCE_NAME, LIMIT from dba_profiles order by PROFILE, RESOURCE_NAME
/
