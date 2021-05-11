select owner, object_type, count(*) from dba_objects 
where owner not like '%SYS%'
 and owner not in ('DBSNMP','OUTLN')
group by owner, object_type
order by owner
/

