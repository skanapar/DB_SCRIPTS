set serveroutput on size 100000
Declare
v_shared_pool_size number ;
v_pct_used number ;
v_threshhold number := 10;
Begin
dbms_output.put_line('Thresshold : '||v_threshhold );

select s.bytes,
100-(s.bytes/p.value)*100 pct
into v_shared_pool_size,v_pct_used
from v$sgastat s ,v$parameter p
where s.name ='free memory'
and p.name ='shared_pool_size'
and s.pool='shared pool';

if ( v_pct_used > v_threshhold ) then
dbms_output.put_line('PCT USED > threshold : '||v_pct_used);
else
dbms_output.put_line('PCT USED < threshold : '||v_pct_used);
end if;
End;
/
