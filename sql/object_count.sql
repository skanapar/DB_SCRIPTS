undef ownr
select owner, object_type, count(*) from dba_objects 
where owner=decode('&&ownr',null,owner,'&&ownr')
group by owner, object_type
order by owner, object_type
/
