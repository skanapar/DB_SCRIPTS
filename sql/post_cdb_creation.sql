alter system set streams_pool_size=512M scope=both sid='*';
alter system set db_flashback_retention_target=1440;
--alter system set use_large_pages=only ;
--alter database flashback on;
alter system set standby_file_management='AUTO' ;
--alter database force logging;
alter system set AWR_SNAPSHOT_TIME_OFFSET=1000000;  

-- starting time automaticlly offset by database name
exec dbms_workload_repository.modify_snapshot_settings(interval => 30, retention => 50400); 

alter system set db_block_checking=medium;
set echo on
set serveroutput on
exit

declare
v_db_name varchar2(100);
v_dr_db_name varchar2(100);
begin
for rec in (select name, case when name like 'PRD%'
                               then 'DR1'|| substr(name,4)
                               when name like 'DR1%'
                               then   'PRD'|| substr(name,4)
                                else name end dr_db_name
 from v$database)
loop
if rec.name <> rec.dr_db_name
then
dbms_output.put_line ('alter system set log_archive_config = ''DG_CONFIG=('|| rec.name||','||rec.dr_db_name||')'' scope=both sid=''*''');
execute immediate 'alter system set log_archive_config = ''DG_CONFIG=('|| rec.name||','||rec.dr_db_name||')'' scope=both sid=''*''';
end if;
end loop;
end;
/
