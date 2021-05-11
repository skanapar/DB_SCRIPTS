SELECT dbdf.target_name,
  dbdf.tablespace_name,
  ROUND(dbdf.create_bytes/(1024*1024*1024),2) size_gb,
  nvl(dbdf.increment_by,0) increment_by,
  nvl(ROUND(dbdf.max_file_size/(1024*1024*1024),2),0) max_size_gb,
  dbdf.autoextensible,
  dbdf.file_name,
  dbdf.collection_timestamp
FROM sysman.mgmt$db_datafiles dbdf,
  sysman.em_targets emt
WHERE dbdf.target_guid = emt.target_guid
AND emt.target_type    = 'oracle_database’;