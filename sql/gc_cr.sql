set serveroutput on
declare
type  indexByTable is table of varchar2(40) index by binary_integer;
l_inst_id       indexByTable;
l_bblocks        indexByTable;
l_eblocks        indexByTable;
l_btime          indexByTable;
l_etime          indexByTable;
v_dummy number;
v_diff_block number;

begin

select a.inst_id,a.value,b.value BULK COLLECT into l_inst_id,l_bblocks,l_btime from
 (select inst_id, value from gv$sysstat where name = 'global cache cr blocks received' order by inst_id) a,
 (select inst_id, value from gv$sysstat where name = 'global cache cr block receive time' order by inst_id) b
where a.inst_id = b.inst_id;

dbms_lock.sleep(1);

select a.inst_id,a.value,b.value BULK COLLECT into l_inst_id,l_eblocks,l_etime from
 (select inst_id, value from gv$sysstat where name = 'global cache cr blocks received' order by inst_id) a,
 (select inst_id, value from gv$sysstat where name = 'global cache cr block receive time' order by inst_id) b
where a.inst_id = b.inst_id;

      dbms_output.put_line(rpad('INST_ID',10,' ')||rpad('BLOCKS_RECIVED',20,' ')||rpad('RECEIVE_TIME(ms)',20,' ')||rpad('RECEIVE_TIME/BLOCK(ms)',25,' '));
      for i in 1 .. l_inst_id.count
      loop
        v_diff_block := l_eblocks(i)-l_bblocks(i);
        if (v_diff_block = 0) then
        v_diff_block := 1;
        end if;
 dbms_output.put_line( rpad(l_inst_id(i),10)||' '||rpad(v_diff_block-1,20)||' '||
                       rpad(to_char(((l_etime(i)-l_btime(i)))*10,'00.00'),20)||
                       rpad(to_char(((l_etime(i)-l_btime(i))/v_diff_block)*10,'00.00'),25));

      end loop;

end;
/
