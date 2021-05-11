--oem_filesystem_usage_across_hosts.sql

select target_name, mountpoint,
round((freeb/1073741824),2) as "Free, GiB",
round((sizeb/1073741824),2) as "Size, GiB",
round((usedb/1073741824),2) as "Used, GiB",
round((((sizeb-freeb)/sizeb)*100),2) as "Used, %"
from MGMT$STORAGE_REPORT_LOCALFS
where filesystem_type not in ('iso9660','devtmpfs') -- excluding some filesystems
order by "Used, %" desc
