set lines 132 pages 100
col machine for a50
select machine,count(*) from v$session group by machine;
