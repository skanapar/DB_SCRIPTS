SELECT -- find children
cc.OWNER "OWNER"
,cc.table_name "CHILD TABLE"
,cc.column_name "CHILD_COLUMN_NAME"
, c.constraint_name "CONSTRAINT_NAME"
, r.table_name PARENT_TABLE
--, rc.column_name PARENT_COLUMN
  FROM dba_constraints c,
       dba_constraints r,
       dba_cons_columns cc,
       dba_cons_columns rc
 WHERE c.constraint_type = 'R'
   AND c.r_owner = r.owner
   AND c.r_constraint_name = r.constraint_name
   AND c.constraint_name = cc.constraint_name
   AND c.owner = cc.owner
   AND r.constraint_name = rc.constraint_name
   AND r.owner = rc.owner
   AND cc.position = rc.position
   AND not exists (select 1 from dba_ind_columns
                   where  index_owner = cc.owner
                   and    table_name = cc.table_name
                   and    column_name = cc.column_name
                   and    column_position = cc.position)
   AND c.owner not in ('SYS', 'SYSTEM', 'MDSYS', 'EXFSYS',
                       'SYSMAN', 'DBSNMP', 'OLAPSYS')        
 ORDER BY c.table_name, c.constraint_name, cc.position;