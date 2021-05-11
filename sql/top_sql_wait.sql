 set line 120
column USER_IO_WAIT format 999999999999999
select * from (
select 
--trim(dbms_lob.substr(a.sql_fulltext,4000,1)) sql_ftxt,
a.sql_id,
max(b.username) username,
sum(a.BUFFER_GETS)/sum(decode(a.EXECUTIONS,0,1,a.EXECUTIONS)) lio,
sum(a.executions) noexe,
sum(APPLICATION_WAIT_TIME) app_wait,
sum(CONCURRENCY_WAIT_TIME) concurr_wait,
sum(CLUSTER_WAIT_TIME) cluster_wait,
sum(USER_IO_WAIT_TIME) user_IO_wait
from v$sqlarea a,dba_users b
where b.user_id= a.PARSING_SCHEMA_ID
and b.username not in ('SYS', 'SYSTEM', 'ADMIN' )
--and upper(a.sql_text) not like upper('%all_%')
group by trim(dbms_lob.substr(a.sql_fulltext,4000,1)),a.sql_id
)
where rownum <11
and noexe > 1
order by user_IO_wait desc, lio desc
/
