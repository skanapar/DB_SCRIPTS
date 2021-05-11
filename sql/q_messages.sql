select
  (nvl(deq_time, sysdate) - enq_time)*24*60*60 as q_dq_secs_wait, MSG_STATE,ENQ_TIMESTAMP,
  PROPAGATED_MSGID, DEQ_TIMESTAMP, ADDRESS
from CMIS.AQ$UDTFROMCERT_QT q
where
  trunc(enq_time) = trunc(sysdate)
  and (nvl(deq_time, sysdate) - enq_time)*24*60*60 > 120
  --and corr_id = 'SE'
  --and msg_state <> 'PROCESSED'
order by
  q_dq_secs_wait desc;