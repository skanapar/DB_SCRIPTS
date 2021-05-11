-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2008 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : asm_disks.sql                                                   |
-- | CLASS    : Automatic Storage Management                                    |
-- | PURPOSE  : Provide a summary report of all disks contained within all disk |
-- |            groups. This script is also responsible for queriing all        |
-- |            candidate disks - those that are not assigned to any disk       |
-- |            group.                                                          |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN disk_group_name        FORMAT a20           HEAD 'Disk Group Name'
COLUMN disk_file_path         FORMAT a20           HEAD 'Path'
COLUMN disk_file_name         FORMAT a20           HEAD 'File Name'
COLUMN disk_file_fail_group   FORMAT a20           HEAD 'Fail Group'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'File Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'

break on report on disk_group_name skip 1

compute sum label ""              of total_mb used_mb on disk_group_name
compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    NVL(a.name, '[CANDIDATE]')                       disk_group_name
  , b.path                                           disk_file_path
  , b.name                                           disk_file_name
  , b.failgroup                                      disk_file_fail_group
  , b.total_mb                                       total_mb
  , (b.total_mb - b.free_mb)                         used_mb
  , case 
      when b.total_mb > 0 
      then ROUND((1- (b.free_mb / b.total_mb))*100, 2) 
      else null 
    end                                              pct_used
FROM
    v$asm_diskgroup a RIGHT OUTER JOIN v$asm_disk b USING (group_number)
ORDER BY
    a.name
/
