--set linesize 300
--spool index_quality_report.txt
 
SELECT i.table_name, i.index_name, t.num_rows, t.blocks, i.clustering_factor,
case when nvl(i.clustering_factor,0) = 0                                    then 'No Stats'
     when nvl(t.num_rows,0) = 0                                             then 'No Stats'
     when (round(i.clustering_factor / t.num_rows * 100)) < 6               then 'Excellent    '
     when (round(i.clustering_factor / t.num_rows * 100)) between 7 and 11  then 'Good'
     when (round(i.clustering_factor / t.num_rows * 100)) between 12 and 21 then 'Fair'
     else                                                                        'Poor'
     end  Index_Quality,
     i.avg_data_blocks_per_key, i.avg_leaf_blocks_per_key,
     to_char(o.created,'DD-MM-YY') CREATION_DATE,
     to_char(o.created,'HH24:MI:SS') CREATION_TIME
from dba_indexes i, dba_objects o, dba_tables t
where i.owner = 'SAPSR3'
and   t.num_rows > 0
--and  (round(i.clustering_factor / t.num_rows * 100)) > 19
and   i.index_name = o.object_name
and   i.table_name = t.table_name
order by 3 desc;
 
--spool off
