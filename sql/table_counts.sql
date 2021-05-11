set timing on;
set pages 50000;
col count format 999,999,999;
select  table_name,to_number(extractvalue(xmltype(dbms_xmlgen.getxml('select /*+ parallel(10) */ count(*) c from "'||table_name||'"')),'/ROWSET/ROW/C')) /*+ parallel(10) */ count from user_tables;
