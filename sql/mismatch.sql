select s.owner "Source Schema" , t.owner "Target Schema",
 s.table_name "Table Name", s.row_count "Source Count", t.row_counts "Target Count"
 from
 mig_row_counts t full outer join mig_user.mig_row_counts@src_dblink s
 on( decode(s.owner,'XXX', 'YYYY' , 'AAA','BBBB')=t.owner
 and s.table_name=t.table_name)
 where nvl(s.row_count,0) <> nvl(t.row_counts,0)
 order by 1,3
 / 
