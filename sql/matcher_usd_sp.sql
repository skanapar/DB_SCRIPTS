compute sum of mb on report
break on report
select segment_type, sum(bytes)/1048576 mb from dba_segments where segment_name in
( select table_name as segment_name from dba_tables where table_name like '%MATCH%'
union
select index_name as segment_name from dba_indexes where table_name like '%MATCH%'
)
and owner='FINANCIALS'
group by segment_type
/
