--Unschedule propagation
Begin
 DBMS_AQADM.UNSCHEDULE_PROPAGATION(queue_name => '<queue_name>',
                                   destination => '<destination>');
End;
WHERE <destination> can be determined and chosen by executing the below query at the schema:
     SELECT destination
       FROM user_queue_schedules
      WHERE qname = <queue_name>;
--Schedule propagation
Begin
 DBMS_AQADM.SCHEDULE_PROPAGATION(queue_name  => '<queue-name>',
                                 destination => '<dblink_name>');
End;
/