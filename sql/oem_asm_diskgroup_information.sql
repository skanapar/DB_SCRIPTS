--oem_asm_diskgroup_information.sql

select target_name,
               target_type target_type,
               key_value dg_name,
               max(decode(column_label,'Disk Group Usable Free
(MB)',maximum,0))/1024 used_space_gb,
               max(decode(column_label,'Disk Group Usable
(MB)',maximum,0))/1024 alloc_space_gb,
           trunc(rollup_timestamp) stat_timestamp
          from SYSMAN.MGMT$METRIC_DAILY a
         where target_type in ('osm_instance','osm_cluster')
           and column_label in ('Disk Group Usable (MB)','Disk Group Usable
Free (MB)')
           and rollup_timestamp>=trunc(sysdate-1)
           and trunc(rollup_timestamp)=trunc(sysdate-1)
           and not exists (select 'a' from SYSMAN.MGMT$TARGET_MEMBERS where
aggregate_target_type='osm_cluster' and member_target_name=a.target_name
and member_target_type='osm_instance')
         group by target_name,target_type,key_value,rollup_timestamp;
         
         