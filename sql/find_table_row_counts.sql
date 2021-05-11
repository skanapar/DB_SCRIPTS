set echo on
spool find_table_row_counts.log;
create table mig_user.mig_row_counts
as
select owner, table_name, count(*) row_count
from dba_tables
where 1=2
group by owner, table_name;
 
truncate table  mig_user.mig_row_counts;
 
set serveroutput on
set serverout on
declare
v_row_count number;             
ls_sql  VARCHAR2(1000) ;
begin
for rec in (select * from dba_tables t
             where owner in  ('&USER1', '&USER2')
             and table_name not like 'BIN$%'
)
loop
 ls_sql :=' insert into dm_mig_user.mig_row_counts select '''||
                   rec.owner ||''','''|| rec.table_name ||''','||
                   ' count(*)  from "'||rec.owner ||'"."'|| rec.table_name||'"' ;
BEGIN
 execute immediate ls_sql;
 commit;
exception when others then
dbms_output.put_line (sqlerrm);
dbms_output.put_line (ls_sql);
end;
end loop;
 
end;
/
commit
/
spool off;
