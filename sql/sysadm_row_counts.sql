set timing on;
set pages 50000;
col count format 999,999,999;
col table_name format a30
select  table_name||','||
to_number(extractvalue(xmltype(dbms_xmlgen.getxml('select /*+ parallel(10) */ count(*) c from "'||owner||'"."'||table_name||'"')),
'/ROWSET/ROW/C')) /*+ parallel(10) */
count from dba_tables
where owner ='SYSADM';
 
