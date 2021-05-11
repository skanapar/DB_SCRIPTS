define usern=&1
select u.username, p.PROFILE, p.RESOURCE_NAME, p.LIMIT from dba_users u, dba_profiles p
where u.profile = p.profile
and username=upper('&&usern')
order by RESOURCE_NAME
/