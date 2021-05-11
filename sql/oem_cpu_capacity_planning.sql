--cpu_capacity_planning_from_oem_metrics.sql

with 
-- my apologizes for using natural joins but I love them :),
TARGET_PROPERTIES as (
    select target_guid,property_name,property_value 
    from sysman.MGMT_TARGET_PROPERTIES
    where property_type='INSTANCE'
),
TARGET_PROP_DEFS as (
    select property_name,property_display_name
    from sysman.MGMT$ALL_TARGET_PROP_DEFS 
    where defined_by='SYSTEM'
),
TARGET_LINE_OF_BUSINESS as (
    select target_guid,property_value "Line of Business" 
    from TARGET_PROP_DEFS 
    natural left outer join 
    TARGET_PROPERTIES where property_display_name='Line of Business'
),
TARGET_DEPARTMENT as (
    select target_guid,property_value "Department" 
    from TARGET_PROP_DEFS 
    natural left outer join 
    TARGET_PROPERTIES where property_display_name='Department'
),
TARGET_LIFESYCLE_STATUS as (
    select target_guid,property_value "LifeCycle Status" 
    from TARGET_PROP_DEFS 
    natural left outer join 
    TARGET_PROPERTIES 
    where property_display_name='LifeCycle Status'
),
TARGET_RAC_DATABASES as (
    select member_target_name target_name
    ,member_target_guid target_guid
    ,composite_target_name "RAC Database"
    from sysman.MGMT_TARGET_MEMBERSHIPS
    where composite_target_type='rac_database' 
    and member_target_type='oracle_database'
),
TARGETS_INSTANCES as (
    select target_guid, target_type, type_meta_ver
    ,category_prop_1, target_name 
    from sysman.mgmt_targets 
    where target_type='oracle_database' 
),
METRICS_CPU as (
    select metric_guid
    ,target_type, type_meta_ver, category_prop_1, metric_name
    ,metric_label, key_column, num_keys, column_label
    ,description, short_name, source, eval_func 
    from sysman.mgmt_metrics
    where column_label = 'CPU Usage (per second)'
),
METRICS_1DAY as (
    select target_guid
    ,metric_guid,rollup_timestamp "Day"
    ,value_maximum/100 "Max CPU load"
    from sysman.mgmt_metrics_1day
),
"CPU load/instance/day" as (
    select "Line of Business","Department","LifeCycle Status"
    ,"RAC Database",target_name "Instance","Day","Max CPU load"
    -- sums over the RAC cluster because we should afford running all services on one instance (but sum of max can be large when a service has been relocated during the day)
    ,sum("Max CPU load") over (partition by "Line of Business","Department","LifeCycle Status","RAC Database","Day") "Sum instances CPU load"
    -- or just need to ensure that each node can run the maximum observed per node
    ,max("Max CPU load") over (partition by "Line of Business","Department","LifeCycle Status","RAC Database","Day") "Max instances CPU load"
    from 
        METRICS_1DAY
    natural join    
        METRICS_CPU
    natural join
        TARGETS_INSTANCES
    natural left outer join
        TARGET_LINE_OF_BUSINESS
    natural left outer join
        TARGET_RAC_DATABASES
    natural left outer join
        TARGET_LIFESYCLE_STATUS
    natural left outer join
        TARGET_DEPARTMENT
),
"Target CPU load/instance/day" as (
    select "Line of Business","Department","LifeCycle Status","RAC Database","Instance","Day"
    -- choice of the metric used when in RAC:
    --  - "Max CPU load" when not counting relocation of services,
    --  - "Sum instances CPU load" when counting that each nodes can accept the maximum load seen in any node
    --  - "Max instances CPU load" when counting that each node can accept the maximul load seen in the whole cluster
    ,"Max CPU load" "Max CPU"
    from "CPU load/instance/day"
),
"Proposed instance caging" as (
select 
    "Line of Business","Department","LifeCycle Status","RAC Database","Instance"
    ,ceil(max("Max CPU")) "From Max"
    -- here we add a percentile calculation because we do not count expceptional peaks
    ,ceil(percentile_cont(0.99) within group(order by "Max CPU")) "From percentile 99%"
    ,ceil(percentile_cont(0.90) within group(order by "Max CPU")) "From percentile 90%"
    from "Target CPU load/instance/day"
    group by "Line of Business","Department","LifeCycle Status","RAC Database","Instance"
)
select
 "Line of Business","Department","LifeCycle Status"
 ,"RAC Database","Instance" 
 ,sum("From Max")
 ,sum("From percentile 99%"),sum("From percentile 90%")
from "Proposed instance caging"
 group by rollup (
 "Line of Business","Department","LifeCycle Status","RAC Database","Instance"
 )
 order by 
 grouping("Line of Business") desc,grouping("Department") desc,grouping("LifeCycle Status") desc,grouping("RAC Database") desc,grouping("Instance") desc,
 "Line of Business","Department","LifeCycle Status","RAC Database","Instance"
;
