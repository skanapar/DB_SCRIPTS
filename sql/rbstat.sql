set timi on
set pages 30
set lines 110
col name for a13 hea 'RB SEGMENT|NAME'
col hwmsize for 9,999,999 hea 'H.W.MARK|SIZE(K)'
col optsize for 999,999 hea 'OPTIMAL|SIZE(K)'
col wraps   for 999 hea '# OF|WRPS'
col extends for 999 hea '# OF|NEW'
col shrinks for 999 hea '# OF|SHRKS'
col aveshrink for 9,999,999 hea 'AV SHRNK|SIZE(K)'
col aveactive for 9,999,999 hea 'AV ACTVE|SIZE(K)'
col status for a7
col xacts  for 999 hea 'ACTIVE|XACTIONS'
select a.name, b.extents, b.hwmsize/1024 hwmsize,
       b.optsize/1024 optsize, b.wraps, b.extends,
       b.shrinks, b.aveshrink/1024 aveshrink,
       b.aveactive/1024 aveactive, b.status, b.xacts
  from v$rollname a, v$rollstat b
 where a.usn = b.usn
order by 1;
set timi off
