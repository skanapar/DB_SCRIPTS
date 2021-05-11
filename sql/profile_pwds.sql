column profile format a20
column limit format a30
select PROFILE, RESOURCE_NAME, LIMIT, COMMON, INHERITED, IMPLICIT from dba_profiles
where resource_type='PASSWORD'
 order by 1,2
/
