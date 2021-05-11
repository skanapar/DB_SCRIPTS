set serveroutput on
begin
dbms_output.enable(1000);
for rec in (select db_unique_name from v$database)
loop

dbms_output.put_line('alter system set log_archive_config=''DG_CONFIG=('||rec.db_unique_name|| ','||'&2'||')''');
execute immediate 'alter system set log_archive_config=''DG_CONFIG=('||rec.db_unique_name|| ','||'&2'||')''';

end loop;
end;
/
alter system set log_archive_dest_2='SERVICE=&1 ASYNC NOAFFIRM VALID_FOR=(ONLINE_LOGFILES,PRIMARY_ROLE) DB_UNIQUE_NAME=&2' sid='*' scope=both;
alter system set log_archive_dest_state_2=enable scope=both;
whenever sqlerror continue
alter database force logging;
whenever sqlerror exit 99


set serveroutput on
 declare
 v_group_number number;
 v_thread_number number;
 begin

 for rec in (select group#,thread#, bytes from v$log where thread#=1 union
             select group#+1,thread#, bytes from v$log where thread#=1
                and group# = (select max(group#) from v$log
                                where thread#=1
                                 and not exists (select 1 from v$log where thread#=1 and group#=9 )
                               )
            )
 loop
 v_group_number := rec.group#;
 v_thread_number := rec.thread#;
 v_group_number := 40+rec.group#;
 v_thread_number := rec.thread#;
 dbms_output.put_line( ' ALTER DATABASE ADD STANDBY  LOGFILE THREAD ' ||v_thread_number|| ' GROUP  '||  v_group_number ||'   SIZE   ' ||rec.bytes );
 execute immediate  ' ALTER DATABASE ADD STANDBY LOGFILE THREAD ' ||v_thread_number|| ' GROUP  '||  v_group_number ||'   SIZE   ' ||rec.bytes ;
 v_group_number := 50+rec.group#;
 v_thread_number := 1+rec.thread#;
 dbms_output.put_line( ' ALTER DATABASE ADD STANDBY LOGFILE THREAD ' ||v_thread_number|| ' GROUP  '||  v_group_number ||'   SIZE   ' ||rec.bytes );
 execute immediate  ' ALTER DATABASE ADD STANDBY LOGFILE THREAD ' ||v_thread_number|| ' GROUP  '||  v_group_number ||'   SIZE   ' ||rec.bytes ;

 End loop;
 end;
/


