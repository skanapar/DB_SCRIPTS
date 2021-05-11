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



