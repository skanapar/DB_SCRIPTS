/*
oraYAPS - Yet another Performance Script Version .01.

This script pulls important oracle performance variables. This is a
working project and is version .01
Please send enhancement suggestions to cjm@integer.org

get the latest copy from http://www.integer.org

Copyright (C) 2003 Cameron Michelis copying and redistribution of this
file is permitted provided this notice and the above comments are
preserved.
*/



prompt
prompt Rollback Segment Statistics
prompt

col name for a7
col xacts for 9990 head "Actv|Trans"
col InitExt for 990.00 head "Init|Ext|(Mb)"
col NextExt for 990.00 head "Next|Ext|(Mb)"
col MinExt for 99 head "Min|Ext"
col MaxExt for 999 head "Max|Ext"
col optsize for 9990.00 head "Optimal|Size|(Mb)"
col rssize for 9990.00 head "Curr|Size|(Mb)"
col hwmsize for 9990.00 head "High|Water|Mark|(Mb)"
col wraps for 999 head "W|R|A|P|S"
col extends for 990 head "E|X|T|E|N|D|S"
col shrinks for 990 head "S|H|R|I|N|K|S"
col aveshrink for 990.00 head "AVG|Shrink|(Mb)"
col gets head "Header|Gets"
col waits for 99990 head "Header|Waits"
col writes for 999,999,990 head "Total|Writes|Since|Startup|(Kb)"
col wpg for 9990 head "AVG|Writes|Per|HedGet|(bytes)"
set lines 132 pages 40 feed off
break on report
compute sum of gets on report
compute sum of waits on report
compute avg of aveshrink on report
compute avg of wpg on report

select name,
XACTS,
initial_extent/1048576 InitExt,
next_extent/1048576 NextExt,
min_extents MinExt,
max_extents MaxExt,
optsize/1048576 optsize,
RSSIZE/1048576 rssize,
HWMSIZE/1048576 hwmsize,
wraps,
extends,
shrinks,
aveshrink/1048576 aveshrink,
gets,
waits,
writes/1024 writes,
writes/gets wpg
from v$rollstat,v$rollname,dba_rollback_segs
where v$rollstat.usn=v$rollname.usn
and dba_rollback_segs.segment_id=v$rollname.usn
order by name
/


prompt
prompt More Rollback Segment Statistics
prompt

column "Rollback Segment" format a16
column "Size (Kb)" format 9,999,999
column "Gets" format 999,999,990
column "Waits" format 9,999,990
column "% Waits" format 90.00
column "# Shrinks" format 999,990
column "# Extends" format 999,990

Select rn.Name "Rollback Segment", rs.RSSize/1024 "Size (KB)", rs.Gets
"Gets",
rs.waits "Waits", (rs.Waits/rs.Gets)*100 "% Waits",
rs.Shrinks "# Shrinks", rs.Extends "# Extends"
from sys.v_$RollName rn, sys.v_$RollStat rs
where rn.usn = rs.usn;

/

prompt
prompt Yet some More Rollback Segment Statistics
prompt

col RBS format a5 trunc
col SID format 9990
col USER format a10 trunc
col COMMAND format a78 trunc
col status format a6 trunc

SELECT r.name "RBS", s.sid, s.serial#, s.username "USER", t.status,
t.cr_get, t.phy_io, t.used_ublk, t.noundo,
substr(s.program, 1, 78) "COMMAND"
FROM sys.v_$session s, sys.v_$transaction t, sys.v_$rollname r
WHERE t.addr = s.taddr
and t.xidusn = r.usn
ORDER BY t.cr_get, t.phy_io;
/


Prompt
Prompt Cache hit ratio
prompt

select 1-(phy.value / (cur.value + con.value)) "Cache Hit Ratio",
round((1-(phy.value / (cur.value + con.value)))*100,2) "% Ratio"
from v$sysstat cur, v$sysstat con, v$sysstat phy
where cur.name = 'db block gets' and
con.name = 'consistent gets' and
phy.name = 'physical reads';

/

Prompt
Prompt Another Buffer Cache hit ratio Calculation
prompt

column "logical_reads" format 99,999,999,999
column "phys_reads" format 999,999,999
column "phy_writes" format 999,999,999
select a.value + b.value "logical_reads",
c.value "phys_reads",
round(100 * ((a.value+b.value)-c.value) /
(a.value+b.value))
"BUFFER HIT RATIO"
from v$sysstat a, v$sysstat b, v$sysstat c
where
a.statistic# = 38
and
b.statistic# = 39
and
c.statistic# = 40;

/

prompt
prompt Data Dictionary Hit Ratio should be over 90 percent
prompt

select sum(gets) "Data Dict. Gets",
sum(getmisses) "Data Dict. Cache Misses",
round((1-(sum(getmisses)/sum(gets)))*100) "DATA DICT CACHE HIT RATIO",
round(sum(getmisses)*100/sum(gets)) "% MISSED"
from v$rowcache;

/

prompt
prompt Library Cache Miss Ratio
prompt

select sum(pins) "executions",
sum(reloads) "Cache Misses",
round((1-(sum(reloads)/sum(pins)))*100) "LIBRARY CACHE HIT RATIO",
round(sum(reloads)*100/sum(pins)) "% Missed"
from v$librarycache;

/

prompt
prompt More Library Cache stats
prompt


select namespace,
trunc(gethitratio*100) "Hit Ratio",
trunc(pinhitratio*100) "Pin Hit Ratio",
reloads "Reloads"
from v$librarycache;
/

prompt
prompt Another Library Cache Calculation, total reloads should be as
close to 0 as possible.
prompt

column libcache format 99.99 heading 'Percentage' jus cen
select sum(pins) "Total Pins", sum(reloads) "Total Reloads",
sum(reloads)/sum(pins) *100 libcache
from v$librarycache;

/

prompt
prompt Redo Log Buffer should be as close to 0 as possible
prompt

select substr(name,1,30),value
from v$sysstat where name ='redo log space requests';
/

prompt
prompt Redo Log Contention, all ratios less than 1
prompt

SET feedback OFF
COLUMN name FORMAT a15
COLUMN gets FORMAT 99999999
COLUMN misses FORMAT 999999
COLUMN immediate_gets FORMAT 99999999 HEADING 'IMM_GETS'
COLUMN immediate_misses FORMAT 99999999 HEADING 'IMM_MISSES'
PROMPT Examining Contention for Redo Log Buffer Latches...
PROMPT ----------------------------------------------------

SELECT name, gets, misses, immediate_gets, immediate_misses,
Decode(gets,0,0,misses/gets*100) ratio1,
Decode(immediate_gets+immediate_misses,0,0,
immediate_misses/(immediate_gets+immediate_misses)*100) ratio2
FROM v$latch WHERE name IN ('redo allocation', 'redo copy');

/


prompt
prompt Disk Vs. Memory Sorts. Try to keep the disk/memory ratio to less
than .10 by increasing the sort_area_size
prompt


SET HEADING OFF
SET FEEDBACK OFF
COLUMN name FORMAT a30
COLUMN value FORMAT 99999990

SELECT name, value FROM v$sysstat
WHERE name IN ('sorts (memory)', 'sorts (disk)');

/

prompt
prompt Initialization Parameters
prompt

select substr(name,1,35) "Parameter" ,substr(value,1,35) "Value" from
v$parameter order by name asc;

/