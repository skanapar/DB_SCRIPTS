SELECT
      a.session_id,
      username,
      type,
      mode_held,
      mode_requested,
      lock_id1,
      lock_id2
FROM
      sys.v_$session b,
      sys.dba_blockers c,
      sys.dba_lock a

WHERE
      c.holding_session=a.session_id and
      c.holding_session=b.sid
