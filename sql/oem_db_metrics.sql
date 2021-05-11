--db_metrics_from_oem.sql

SELECT mt.target_name, mt.type_qualifier1, mt.host_name, mmd.rollup_timestamp, mmd.metric_name, mmd.metric_column, mmd.metric_label, mmd.column_label, average, minimum, maximum, standard_deviation 
FROM sysman.mgmt$metric_daily mmd 
  JOIN sysman.mgmt$target mt 
    ON mmd.target_name = mt.target_name AND mmd.target_type = mt.target_type AND mmd.target_guid = mt.target_guid
WHERE
mt.target_type = 'oracle_database'
and mt.target_name not in (
'amoempr_amoempr.am.kwe.com',
'amrmanpr.am.kwe.com',
'GMECXPR.GITDAL.KWE.COM',
'AMOIDPR1.AM.KWE.COM',
'AMOIDPR2.AM.KWE.COM'
)
and mmd.rollup_timestamp >= (sysdate - 14)
--and mmd.metric_column like '%cpu%'
and column_label in (
'Allocated Space(GB)',
'Buffer Cache Hit (%)',
'Database CPU Time (%)',
'CPU Usage (per second)',
'PGA Cache Hit (%)',
'Database Time (centiseconds per second)',
'Physical Reads (per second)',
'Physical Writes (per second)',
'Redo Writes (per second)',
'Wait Time (%)',
'Active Sessions Waiting: I/O',
'Database Time Spent Waiting (%)',
'Sorts in Memory (%)')
order by mt.target_name, mmd.metric_name, mmd.metric_column, mmd.rollup_timestamp
/

