set lines 150
set pages 1000
col Diskgroup for a10
col Disk for a60
col failgroup for a20
col "Size (GB)" for 999,999
col "Free (GB)" for 999,999
 select
   g.name "Diskgroup",
   d.path "Disk",
   d.failgroup "Fail Group",
   d.total_mb/1024 "Size (GB)",
   d.free_mb/1024 "Free (GB)"
 from
   v$asm_diskgroup g,
   v$asm_disk d
 where
   d.GROUP_NUMBER=g.GROUP_NUMBER
 order by 1,2
