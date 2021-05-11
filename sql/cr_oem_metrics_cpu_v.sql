-- create oem metrics view for CPU utilization
-- for loading into capman repository

create or replace view oem_metrics_cpu_v as 
select to_char(collection_time,'yyyy/mm/dd hh24:mi') collection_time,
		  entity_name  ,
      metric_column_label ,
      metric_column_name ,
      metric_group_label ,
      VALUE,
      100 as capacity
from SYSMAN.GC$METRIC_VALUES@OEMREPO
    WHERE
      entity_type          = 'host'
    AND metric_column_name = 'cpuUtil'
    AND metric_group_label = 'Load' 
order by entity_type,entity_name,collection_time
;


-- ASM Diskgroup
create view oem_metrics_dgspace_v as 
with pctused as
( select to_char(collection_time,'yyyy/mm/dd hh24:mi') collection_time,
		  entity_name as ASM_cluster,
      KEY_PART_1 as diskgroup,
      VALUE
from SYSMAN.GC$METRIC_VALUES@OEMREPO
    WHERE
      entity_type       = 'osm_cluster'
    AND metric_column_name = 'percent_used'
    AND METRIC_GROUP_NAME = 'DiskGroup_Usage' )
, usable_GB  as
( select to_char(collection_time,'yyyy/mm/dd hh24:mi') collection_time,
		  entity_name as ASM_cluster,
      KEY_PART_1 as diskgroup,
      VALUE
from SYSMAN.GC$METRIC_VALUES@OEMREPO
    WHERE
      entity_type       = 'osm_cluster' -- + osm_instance
    AND metric_column_name = 'usable_total_mb'
    AND METRIC_GROUP_NAME = 'DiskGroup_Usage' ) 
, max_GB as
( select ASM_cluster, diskgroup, max(value) as capacity from usable_GB 
 group by ASM_cluster, diskgroup)
select a.collection_time
 ,  b.ASM_cluster || '_' || b.diskgroup as entity
 , 'Diskgroup Used DG' as metric_column_label 
 , 'used_GB' as metric_column_name
 , a.value* b.value as VALUE
 , c.capacity as capacity
 from pctused a, usable_GB b, max_GB c
 where a.collection_time = b.collection_time
 and a.ASM_cluster = b.ASM_cluster
 and a.diskgroup = b.diskgroup
 and a.ASM_cluster = c.ASM_cluster
 and a.diskgroup = c.diskgroup
 
 -- AAS
 create view oem_metrics_aas_v as
with db_hosts as 
( select distinct SOURCE_TARGET_NAME dbinstance,ASSOC_TARGET_NAME dbhost
from sysman.MGMT$TARGET_ASSOCIATIONS@OEMREPO
where SOURCE_TARGET_type = 'oracle_database' 
and ASSOCIATION_TYPE = 'hosted_by')
, hw_cpu as
(select target_name dbhost, sum(instance_count*siblings ) tot_cpu
from  sysman.MGMT$HW_CPU_DETAILS@OEMREPO d
group by target_name)
select to_char(collection_time,'yyyy/mm/dd hh24:mi') collection_time,
		  entity_name  ,
      metric_column_label ,
      metric_column_name ,
      metric_group_label ,
      VALUE,
      h.tot_cpu as capacity
from SYSMAN.GC$METRIC_VALUES@OEMREPO a, hw_cpu h , db_hosts d
    WHERE
      entity_type          = 'oracle_database'
    AND metric_column_name = 'avg_active_sessions'
    AND metric_group_label = 'Throughput' 
    and a.entity_name = d.dbinstance
    and d.dbhost = h.dbhost
 
    
-- IOPS
create or replace view oem_metrics_iops_v as 
select to_char(collection_time,'yyyy/mm/dd hh24:mi') collection_time,
		  entity_name  ,
      metric_column_label ,
      metric_column_name ,
      metric_group_label ,
      VALUE,
      null as capacity
from SYSMAN.GC$METRIC_VALUES@OEMREPO
    WHERE
      entity_type          = 'oracle_database'
    AND metric_column_name = 'iorequests_ps'
    AND metric_group_label = 'Throughput' 
order by entity_type,entity_name,collection_time
;

   
-- MBPS
create or replace view oem_metrics_mbps_v as 
select to_char(collection_time,'yyyy/mm/dd hh24:mi') collection_time,
		  entity_name  ,
      metric_column_label ,
      metric_column_name ,
      metric_group_label ,
      VALUE,
      null as capacity
from SYSMAN.GC$METRIC_VALUES@OEMREPO
    WHERE
      entity_type          = 'oracle_database'
    AND metric_column_name = 'iombs_ps'
    AND metric_group_label = 'Throughput' 
order by entity_type,entity_name,collection_time
;