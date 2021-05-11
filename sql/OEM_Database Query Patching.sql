"select  --db_type,
BU, LIFE_CYCLE, PATCH_GROUP, listagg(database_name, ',')  within group (order by database_name) as databases
from(
select distinct database_name, db_type, 
case when BU='OTHER' and database_name like '%MAX%' then  'CORPORATE'
          else BU end BU
, LIFE_CYCLE, PATCH_GROUP
from(
select database_name,db_type, instance_name, host_name, creation_date,dbversion, startup_time, BU,LIFE_CYCLE, 
CASE WHEN DATABASE_NAME LIKE 'COG%' THEN 'DECOMMISSION'
          WHEN BU='TXU' and LENGTH(DATABASE_NAME)=3 THEN 'SAP'
          WHEN BU='LUMINANT' and  upper(host_name) not like '%MAX%'   THEN 'LUMINANT'
          WHEN BU='LUMINANT' and  upper(host_name) not like '%MAX%'   THEN 'CORPORATE'
          WHEN BU='CORPORATE' THEN 'CORPORATE'
          WHEN BU='TXU' and PATCH_GROUP='OTHER' THEN 'ANCILLARY'
ELSE
PATCH_GROUP END PATCH_GROUP
from
(
select database_name,instance_name, host_name, creation_date,dbversion, startup_time, 
        case  upper(substr(host_name, 3,2) )
          when 'PR'  then 'PROD'  
          when 'DR'  then 'DR' 
          when 'PP' then 'PRE-PROD' 
          when 'DV' then 'DEVELOPMENT'
          when 'TS' then 'TEST'
        --  when 'TR' then 'TRAINING'
    --    when 'QA' then 'QA'
             when 'TR' then 'TEST'
           when 'QA' then 'TEST'
          ELSE  'OTHER' END Life_cycle,
              case  upper(substr(host_name, 1,1) )
          when 'T'  then 'TXU'  
          when 'L'  then 'LUMINANT' 
          when 'E' then 'CORPORATE' 
          ELSE   'OTHER' END  BU
          ,
                  case  upper(substr(host_name, 8,3))
          when 'ANC'  then 'ANCILLARY'  
          when 'SAP'  then 'SAP' 
          when 'GEN' then 'GENESYS' 
          when 'EP1' then 'CORPORATE'
          when 'EP2' then 'EP2'
          when 'LUM' then 'LUMINANT'
          ELSE  'OTHER' END  PATCH_GROUP,
              case  upper(substr(host_name, 5,3))
          when 'RAC'  then 'RAC'  
          ELSE  'SINGLE' END  DB_TYPE
from sysman.MGMT_DB_DBNINSTANCEINFO_ECM
where startup_time >sysdate -400
and dbversion  not like '10.2%'
order by database_name)
)
order by patch_group, life_cycle
)
where patch_group not like 'DECOMM%'
group by --db_type, 
BU, LIFE_CYCLE, PATCH_GROUP
order by life_cycle, patch_group
--where patch_group = 'OTHER'
"