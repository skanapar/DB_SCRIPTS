set line 120
set pagesize 200
column name format a50
column codelevel format a10
column baseline format a10
select abbreviation, name, codelevel, baseline
  from apps.ad_trackable_entities where type = 'product'
  order by type desc, 1
/
