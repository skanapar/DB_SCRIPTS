SELECT substr(s1.username,1,12)    "WAITING User",
       substr(s1.osuser,1,8)            "OS User",
       substr(to_char(w.session_id),1,5)    "Sid",
       P1.spid                              "PID",
       substr(s2.username,1,12)    "HOLDING User",
       substr(s2.osuser,1,8)            "OS User",
       substr(to_char(h.session_id),1,5)    "Sid",
       P2.spid                              "PID"
FROM   sys.v_$process P1,   sys.v_$process P2,
       sys.v_$session S1,   sys.v_$session S2,
       dba_locks w,     dba_locks h
WHERE  h.mode_held        = 'None'
AND    h.mode_held        = 'Null'
AND    w.mode_requested  != 'None'
AND    w.lock_type (+)    = h.lock_type
AND    w.lock_id1  (+)    = h.lock_id1
AND    w.lock_id2  (+)    = h.lock_id2
AND    w.session_id       = S1.sid  (+)
AND    h.session_id       = S2.sid  (+)
AND    S1.paddr           = P1.addr (+)
AND    S2.paddr           = P2.addr (+);