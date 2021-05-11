set pagesize 999
set verify off
column name format a50
column value format a28
column default format a7
select a.ksppinm  name, b.ksppstvl Value
-- , c.ksppstvl "Instance Value"
  from x$ksppi a, x$ksppsv b
--, x$ksppsv c
 where a.indx = b.indx
-- and a.indx = c.indx
   and substr(ksppinm,1,1)='_'
  and a.ksppinm like nvl('%&name%',a.ksppinm)
order by 1
/

