select COLUMN_NAME, HIDDEN_COLUMN, VIRTUAL_COLUMN from dba_tab_cols where table_name='&table_name' order by column_id
/
