column object_name format a40
set pages 100
set line 200
select object_type, owner, count(*) from dba_objects group by  object_type, owner having owner='FINANCIALS'
/
