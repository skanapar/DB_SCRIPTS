break on table_name skip 1 on index_name skip 1
col table_name for a23
col index_name for a30
col index_type for a25
col COLUMN_NAME for a20
col pos for 999
set linesize 140
set pagesize 200
select a.table_name, a.index_name, --status, --tablespace_name
--b.index_type index_type,
UNIQUENESS, a.COLUMN_POSITION pos, a.COLUMN_NAME , DESCEND--, b.INDEX_TYPE
from user_ind_columns a , user_indexes b
where a.TABLE_NAME =  upper('&TABLENAME')
and a.INDEX_NAME=b.INDEX_NAME
and a.TABLE_NAME=b.TABLE_NAME
order by 1,2,4
/
