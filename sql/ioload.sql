set serveroutput on size 10000
Declare
p_timetorun number := 60 ;
p_frequency number := 5 ;
p_waitbetween number := 60;
v_reads  number :=0;
v_writes  number :=0;
v_bredo number := 0;
v_eredo number := 0;
bpr  number :=0;
bpwr number :=0;
epr  number :=0;
epwr number :=0;
v_starttime date ;
v_sysdate date ;
v_timetorun number := p_timetorun;
intl number ;
ttot number;
waitbetween number := p_waitbetween;
inst varchar2(20);
begin
select sysdate into v_starttime from dual;

intl := p_frequency;

--while ( (sysdate - v_starttime)*(24*60) < v_timetorun )
--while ( 1<2 )
--loop
v_sysdate := sysdate;

begin

select sum(PHYBLKRD),sum(PHYBLKWRT)
into bpr,bpwr
from
(
select PHYBLKRD,PHYBLKWRT from v$tempstat
 union
select PHYBLKRD,PHYBLKWRT from v$filestat
);

select value into v_bredo from v$sysstat where name like 'redo writes';

dbms_lock.sleep(intl);

select sum(PHYBLKRD),sum(PHYBLKWRT)
into epr,epwr
from
(
select PHYBLKRD,PHYBLKWRT from v$tempstat
 union
select PHYBLKRD,PHYBLKWRT from v$filestat
);

select value into v_eredo from v$sysstat where name like 'redo writes';

v_reads := (epr-bpr)/intl;
v_writes := (epwr-bpwr)/intl+(v_eredo-v_bredo)/intl;

ttot := v_reads+v_writes;

dbms_output.put_line('BlockReads/Sec # '||v_reads||' BlockWrites/Sec # '||v_writes || '  Total # ' || ttot);
end;
--end loop;
end;
/
