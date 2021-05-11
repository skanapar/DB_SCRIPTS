show pdbs

--alter session set container=&container_name
--/

alter system set  "_unnest_subquery"=false  scope=both
/

set lines 200
col name format a40
col value format a40

select name, value from v$parameter where name like '%unnest%'
/

exit


