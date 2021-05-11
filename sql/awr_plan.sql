set lines 150
SELECT * FROM table(dbms_xplan.display_awr(nvl('&sql_id','a96b61z6vp3un'),null,null,'typical +peeked_binds'))
/
