set head off
SET PAGES
spool mio.sql
select 'insert into CERT 
	select EMPNO, '''||column_name||''',null,null from CERT_DAT
	where '||column_name||' = ''TRUE'';'
from user_tab_columns where table_name = 'CERT_DAT';
spool off
