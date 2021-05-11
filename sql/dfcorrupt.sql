set lines 132 pages 1000

col name format a40 heading "Datafile";
col corrupt_date heading "Date of |Corruption";

spool dfcorrupt.lis

select vd.name,to_char(vd.unrecoverable_time,'dd-MON-yyyy:hh24:mi:ss')
corrupt_date
from v$datafile vd, v$backup vb
where vd.file#=vb.file#
and vd.unrecoverable_time is not null
order by 2 desc;

spool off;
clear columns;