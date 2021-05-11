--
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN index_name      FORMAT A30
COLUMN column_name     FORMAT A30
COLUMN column_position FORMAT 99999
COLUMN partitioned FORMAT A3
COLUMN locality FORMAT A6
COLUMN unusable_part FORMAT A6 HEADING 'UNUS_PARTS'
COLUMN unusable_subpart FORMAT A6 HEADING 'UNUS_SUBPARTS'
break on index_name nodup

SELECT a.index_name,
       a.column_name,
       a.column_position,
	   b.partitioned,
	   p.locality,
	   (select decode(count(*),0,'NO','YES') from dba_ind_partitions where index_name=a.index_name and status='UNUSABLE')  as unusable_part,
       (select decode(count(*),0,'NO','YES') from dba_ind_subpartitions where index_name=a.index_name and status='UNUSABLE') as unusable_subpart
FROM   dba_ind_columns a,
       dba_indexes b,
	   dba_part_indexes p	   
WHERE  b.table_name = Upper('&&2')
AND    b.owner      = Upper('&&1')
AND    b.index_name = a.index_name
AND    b.owner      = a.index_owner
AND    b.index_name = p.index_name(+)
ORDER BY 1,3;

SET PAGESIZE 18
SET VERIFY ON