set lines 200
 col sid format 9999
 col serial# format 9999
 col username format A10
 col machine format A30
 col program format A30
 col sql_text format A45 word_wrap
 select s.sid,s.serial#,s.username,s.machine,p.program,q.sql_text
   from v$sqlarea q,v$session s,v$process p
  where q.address(+) = s.sql_address
    and s.paddr  =  p.addr
    and p.spid  = '&1'
--    and p.spid  in (6781,6374,7564,7099)
/
