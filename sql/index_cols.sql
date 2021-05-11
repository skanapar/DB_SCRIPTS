accept owner char prompt "Enter table owner : "
accept table_name char prompt "Enter table name [like]: "

set pages 90
set lines 132
clear breaks
break on tab_name on ind_name on distinct_keys on uniqueness skip 1
col tab_name format a30 heading "Table Name"
col ind_name format a30 heading "Index Name"
col col_name format a30 heading "Indexed Columns Positions"
col distinct_keys format 999999 heading "Distinct|Keys"

select          di.table_owner||'.'||di.table_name              tab_name
,               di.owner||'.'||di.index_name                    ind_name
,               di.distinct_keys
,               di.uniqueness
,               dic.column_position||' '||dic.column_name       col_name
from            dba_ind_columns dic
,               dba_indexes     di
where           DECODE('&&owner',NULL,'x',di.table_owner) = NVL(upper('&&owner'),'x')
and             DECODE('&&table_name',NULL,'x',di.table_name) like NVL(upper('&&table_name'),'x')
and             di.index_name = dic.index_name
and             di.table_name = dic.table_name
and             di.owner = dic.index_owner
/

