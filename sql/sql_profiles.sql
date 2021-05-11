select * from dba_sql_profiles
where sql_text like nvl('&sql_text',sql_text)
order by last_modified
/
