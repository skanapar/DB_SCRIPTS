set serveroutput on size 10000
Declare
p_frequency number := 5 ;
v_reads  number :=0;
v_writes  number :=0;
bpr  number :=0;
bpwr number :=0;
epr  number :=0;
epwr number :=0;
v_starttime date ;
v_sysdate date ;
intl number ;
ttot number;

begin

select sysdate into v_starttime from dual;
intl := p_frequency;
v_sysdate := sysdate;

select sum(PHYBLKRD),sum(PHYBLKWRT)
into bpr,bpwr
from v$filestat;

dbms_lock.sleep(intl);

select sum(PHYBLKRD),sum(PHYBLKWRT)
into epr,epwr
from v$filestat;

v_reads := (epr-bpr)/intl;
v_writes := (epwr-bpwr)/intl;

ttot := v_reads+v_writes;

dbms_output.put_line('BlockReads/Sec # '||v_reads||' BlockWrites/Sec # '||v_writes || '  Total # ' || ttot);

end;
/
