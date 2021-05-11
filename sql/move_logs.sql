cursor rlc is
      select group# grp, thread# thr, bytes/1024 bytes_k, 'NO' srl
        from v$log
      union
      select group# grp, thread# thr, bytes/1024 bytes_k, 'YES' srl
        from v$standby_log
      order by 1;
   stmt     varchar2(2048);
   swtstmt  varchar2(1024) := 'alter system switch logfile';
   ckpstmt  varchar2(1024) := 'alter system checkpoint global';
begin
   for rlcRec in rlc loop
      if (rlcRec.srl = 'YES') then
         stmt := 'alter database add standby logfile thread ' ||
                 rlcRec.thr || ' ''&DISKGROUP_NAME'' size ' || 
                 rlcRec.bytes_k || 'K';
         execute immediate stmt;
         stmt := 'alter database drop standby logfile group ' || rlcRec.grp;
         execute immediate stmt;
      else
         stmt := 'alter database add logfile thread ' ||
                 rlcRec.thr || ' ''&DISKGROUP_NAME'' size ' ||  
                 rlcRec.bytes_k || 'K';
         execute immediate stmt;
         begin
            stmt := 'alter database drop logfile group ' || rlcRec.grp;
            dbms_output.put_line(stmt);
            execute immediate stmt;
         exception
            when others then
               execute immediate swtstmt;
               execute immediate ckpstmt;
               execute immediate stmt;
         end;
      end if;
   end loop;
end;
/ 