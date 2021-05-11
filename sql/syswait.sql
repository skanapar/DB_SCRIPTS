set serveroutput on size 1000000
declare
      type  statValueTable is table of NUMBER index by binary_integer;
      type  statNameTable is table of varchar2(64) index by binary_integer;

      l_beginValueTable statValueTable;
      l_beginNameTable  statNameTable;

      l_endValueTable statValueTable;
      l_endNameTable  statNameTable;

      l_value       varchar2(40);

  begin
      dbms_output.put_line( rpad('WaitEvent',64,' ')||' '||'Value');
      dbms_output.put_line( rpad('=========',64,' ')||' '||'=====');
      select EVENT, TOTAL_WAITS BULK COLLECT into l_beginNameTable,l_beginValueTable from V$SYSTEM_EVENT 
      where event not in ( select event from STATS$IDLE_EVENT )
      order by EVENT ;
      
      dbms_lock.sleep(1); -- Sleep for 1 sec
      select EVENT, TOTAL_WAITS BULK COLLECT into l_endNameTable,l_endValueTable from V$SYSTEM_EVENT 
      where event not in ( select event from STATS$IDLE_EVENT )
      order by EVENT ;

      for i in 1 .. l_beginNameTable.count
      loop
      
      if ( l_endValueTable(i)-l_beginValueTable(i) != 0) then
      --dbms_output.put_line( 'StatName '|| l_beginNameTable(i)||' StatValue '||to_char(l_endValueTable(i)-l_beginValueTable(i)) );
      dbms_output.put_line( rpad(l_beginNameTable(i),64,'-')||'> '||to_char(l_endValueTable(i)-l_beginValueTable(i)) );
      end if;
      end loop;


end;
/
