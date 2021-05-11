set long 5000
set linesize 150
set pages 0
set trimspool on

spool alter_SL_SL_ACCOUNTING_EVENTS.sql

select DBMS_METADATA_DIFF.COMPARE_ALTER(
	object_type   => 'TABLE',
	name1         => 'SL_ACCOUNTING_EVENTS',
	name2         => 'SL_ACCOUNTING_EVENTS',
	schema1       => 'FINANCIALS',
	schema2       => 'FINANCIALS',
	network_link1 => null,
	network_link2 => 'mylink.domain') from dual
/
spool off
