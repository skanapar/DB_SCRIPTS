-- dequeue message without processing
Declare
  Payload  sys.xmltype;
  In_queue_name  varchar2 (30) := '<queue_name>';
  deq_opt  dbms_aq.dequeue_options_t;
  msg_prop dbms_aq.message_properties_t;
  msgid raw(16) := 'XXXXXXXXXXXXX';
Begin
  deq_opt.wait := dbms_aq.no_wait;
  dbms_aq.dequeue(In_queue_name, deq_opt, msg_prop, payload, msgid);
  commit;
End;
/