set heading on
set feedback off
set term on
set pagesize 1000
set long 5000
set linesize 150
set trimspool on
column sql_ftxt   heading "SQL||Text"               format a80 wrapped
column lio        heading "Logical I/o||Per Exe"    format 99999999
column noexe      heading "#of|| Executions"        format 99999999
column username   heading "User"                    format a15
column sql_id     heading "SQL ID"                  format a15
column hast_value heading "Hash"                    format a15
break on lio skip 1 on username on noexe on hash_value

spool out/topsql

select * from (
select trim(dbms_lob.substr(a.sql_fulltext,4000,1)) sql_ftxt,
a.sql_id,
max(b.username) username,
sum(a.BUFFER_GETS)/sum(decode(a.EXECUTIONS,0,1,a.EXECUTIONS)) lio,
sum(a.executions) noexe
from v$sqlarea a,dba_users b
where b.user_id= a.PARSING_SCHEMA_ID
and b.username not in ('SYS', 'SYSTEM', 'ADMIN' )
--and upper(a.sql_text) not like upper('%all_%')
group by trim(dbms_lob.substr(a.sql_fulltext,4000,1)),a.sql_id
order by 3 desc)
where rownum <11
and noexe > 1
order by lio desc;

spool off
