SELECT /*+ ORDERED */
       s.sid, s.username, s.osuser, 
       nvl(s.machine, '?') machine, 
       nvl(s.program, '?') program,
       s.process F_Ground, p.spid B_Ground, 
       X.sql_text
FROM   sys.v_$session S,
       sys.v_$process P, 
       sys.v_$sqlarea X
WHERE  s.osuser      like lower(nvl('&OS_User','%'))
AND    s.username    like upper(nvl('&Oracle_User','%'))
AND    s.sid         like nvl('&SID','%')
AND    s.paddr          = p.addr 
AND    s.type          != 'BACKGROUND' 
AND    s.sql_address    = x.address
AND    s.sql_hash_value = x.hash_value
ORDER
    BY S.sid;