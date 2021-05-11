-- enqueue manually a single or multiple messages
DECLARE
 enq_opt    DBMS_AQ.enqueue_options_t;
 msg_prop   DBMS_AQ.message_properties_t;
 msg_id     RAW (16);
 xml_data   SYS.XMLTYPE;
 CURSOR cur_req IS
 SELECT   user_data
   FROM <queuetable_name>
  WHERE state = 3 AND deq_time IS NULL
  ORDER BY enq_time ASC;
BEGIN
 OPEN cur_req;
 LOOP
   BEGIN
     FETCH cur_req INTO xml_data;
     EXIT WHEN cur_req%NOTFOUND;
     IF xml_data IS NOT NULL THEN
       SYS.DBMS_AQ.enqueue ('&SCHEMA..<queue_name>', enq_opt, msg_prop, xml_data, msg_id);
     END IF;
   END;
 END LOOP;
 CLOSE cur_req;
END;
/