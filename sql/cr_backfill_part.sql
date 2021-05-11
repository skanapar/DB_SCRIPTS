set termout on
set serverout on
declare
  initdate date := to_date('20120311','yyyymmdd');
  tabn varchar2(20) := 'SL_AE_ADJUSTMENTS';
  numd integer;
  ct integer;
begin
dbms_output.enable(1000000);
select trunc(sysdate)-trunc(initdate) into numd from dual;
dbms_output.put_line('Partitions for '||tabn||', since '||initdate||', '||numd||' days back');
for ct in reverse 1..numd
loop
	dbms_output.put_line(to_char(ct)||'.. ');
  admin.DW_PARTITION_UTIL.CREATE_PARTITIONS(
    P_OWNER=>'FINANCIALS',
	P_TABLE_NAME=>tabn,
	P_DATE=>sysdate-ct);
end loop;
end;
/
