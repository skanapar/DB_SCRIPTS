  declare
  begin
    for c1_rec in (
                    select *
                    from gv$lock
                   where --lmode=6 and
                     block>0
                     and (ID1,ID2) in
                         (select id1,id2
                             from gv$lock
                             where type like 'TX' and REQUEST >0)
               )
    loop
          dbms_output.put_line('Holding Session:');
          dbms_output.put_line('----------------');
          for sess_rec in (
             select s.username, s.osuser, s.program, p.pid, p.spid unxproc, s.process , s.serial#, s.status
             from gv$session s, gv$process p
             where s.inst_id=p.inst_id and s.sid=c1_rec.sid and p.addr=s.paddr
                     and c1_rec.inst_id=s.inst_id and rownum=1)
     loop
            dbms_output.put('Sid,serial#='||c1_rec.sid||','||sess_rec.serial#
                              ||'.Instance#='||c1_rec.inst_id);
            dbms_output.put(',Status='||sess_rec.Status||',Username='||sess_rec.username);
            dbms_output.put_line(',Osuser='||sess_rec.username);
               dbms_output.put('     ,Pid='||sess_rec.pid||', Unxproc(spid)='||sess_rec.unxproc||', ClientProcess='||sess_rec.process);
            dbms_output.put(',LockType='||c1_rec.type);
            dbms_output.put_line(',Mins_held='||round(c1_rec.ctime/60));
            dbms_output.put_line('-          Program='||sess_rec.program);
       dbms_output.new_line;
     end loop;
     dbms_output.put_line('-');
          dbms_output.put_line('Waiting Sessions:');
          dbms_output.put_line('-----------------');
          for c2_rec in ( select *
                       from gv$lock
                       where id1=c1_rec.id1 and id2=c1_rec.id2
                             and ((inst_id=c1_rec.inst_id and sid!=c1_rec.sid )
                                     or inst_id!=c1_rec.inst_id )
                     )
          loop
             for sess_rec in (
                select s.username, s.osuser, s.program, p.pid, p.spid unxproc, s.process, s.serial#, s.status
                from gv$session s, gv$process p
                where s.inst_id=p.inst_id and s.sid=c2_rec.sid
                      and p.addr=s.paddr and c2_rec.inst_id=s.inst_id and rownum=1)
        loop
               dbms_output.put('Sid,serial#='||c2_rec.sid||','||sess_rec.serial#
                              ||'.Instance#='||c2_rec.inst_id);
               dbms_output.put(',Status='||sess_rec.Status||',Username='||sess_rec.username);
               dbms_output.put_line(',Osuser='||sess_rec.username);
               dbms_output.put('     ,Pid='||sess_rec.pid||', Unxproc(spid)='||sess_rec.unxproc||', ClientProcess='||sess_rec.process);
               dbms_output.put(',LockType='||c2_rec.type);
               dbms_output.put_line('-               Program='||sess_rec.program);
          dbms_output.new_line;
        end loop;
          end loop;
    end loop;
 end;
/
