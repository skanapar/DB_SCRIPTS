-- Begin DDL Extract of Trigger SYS.AURORA$SERVER$SHUTDOWN
-- Extracted from DDW2 by SYSTEM
-- Extracted at 10:06:50, 01/08/2001

CREATE OR REPLACE TRIGGER SYS.AURORA$SERVER$SHUTDOWN
  BEFORE
  ON SYS.dbms_java.server_shutdown
;

/

-- End DDL Extract of Trigger SYS.AURORA$SERVER$SHUTDOWN

-- Begin DDL Extract of Trigger SYS.AURORA$SERVER$STARTUP
-- Extracted from DDW2 by SYSTEM
-- Extracted at 10:06:50, 01/08/2001

CREATE OR REPLACE TRIGGER SYS.AURORA$SERVER$STARTUP
  AFTER
  ON SYS.dbms_java.server_startup
;

/

-- End DDL Extract of Trigger SYS.AURORA$SERVER$STARTUP

-- Begin DDL Extract of Trigger SYS.PUBLISH_LOGON
-- Extracted from DDW2 by SYSTEM
-- Extracted at 10:06:50, 01/08/2001

CREATE OR REPLACE TRIGGER SYS.PUBLISH_LOGON
  AFTER logon
  ON DEMO_BI.SCHEMA
declare

     v_session_user varchar2(30);
     v_os_user varchar2(30);
     v_sessionid number;
     v_msg varchar2(1000);
     v_host varchar2(300);
     v_ip_address varchar2(20);
     v_current_schema varchar2(300);
     v_db_name varchar2(300);
     v_isdba varchar2(6);
     v_client_info varchar2(64);
     v_connected varchar(3);


    begin

    /* execute immediate 'alter session set current_schema = SYS'; */

     v_msg := 'CAN NOT DO THAT';
     v_connected := 'YES';

   if LOGIN_USER != 'LMS'
   then

      SELECT sys_context('USERENV','SESSION_USER'),
             sys_context('USERENV','OS_USER'),
             sys_context('USERENV','SESSIONID'),
             sys_context('USERENV','HOST'),
             sys_context('USERENV','IP_ADDRESS'),
             sys_context('USERENV','CURRENT_SCHEMA'),
             sys_context('USERENV','DB_NAME'),
             sys_context('USERENV','CLIENT_INFO'),
             sys_context('USERENV','ISDBA')
        INTO v_session_user,
            v_os_user,
            v_sessionid,
            v_host,
            v_ip_address,
            v_current_schema,
            v_db_name,
            v_client_info,
            v_isdba
            FROM dual;



      insert into login_attempt values
                                      (v_session_user,
                                       v_os_user,
                                       v_sessionid,
                                       v_host,
                                       v_current_schema,
                                       v_db_name,
                                       v_ip_address,
                                       v_isdba,
                                       v_client_info,
                                       v_connected,
                                       sysdate);
      commit;

     end if;



END;


/

-- End DDL Extract of Trigger SYS.PUBLISH_LOGON

-- Begin DDL Extract of Trigger SYS.TRAP_ERROR
-- Extracted from DDW2 by SYSTEM
-- Extracted at 10:06:50, 01/08/2001

CREATE OR REPLACE TRIGGER SYS.TRAP_ERROR
  after insert
  or delete
  ON SYS.
begin
     declare

     v_code number;
     v_body varchar2(512);
     v_subject varchar(512);
     v_mail_list varchar2(1000);
     x number;
     v_alert_level number;
     v_error_num number;
     v_l_feed  varchar2(10) := chr(10);
     v_error_text varchar2(512);
     error_list_rec error_tab%ROWTYPE;
     mail_list_rec mail_list%ROWTYPE;
     v_inform number;

     CURSOR mail_list_cur IS

       select *
       from mail_list
       where alert_level = v_alert_level;

begin

     v_inform := 0;
     x := 1;

     while server_error(x) != 0
     loop
          v_error_num := server_error(x);
          v_error_text := sqlerrm(-v_error_num);

         begin

            select * into
                     error_list_rec
            from error_tab
            where error_num = v_error_num;

            v_alert_level := error_list_rec.alert_level;

         exception

            when no_data_found then null;

         end;



          if (error_list_rec.error_num is NOT NULL) and (v_inform = 0)
          then

               v_inform := 1;

          end if;

          begin
                OPEN mail_list_cur;
                LOOP
                      FETCH mail_list_cur into mail_list_rec;
                      exit when mail_list_cur%NOTFOUND;

                     v_mail_list := v_mail_list || '  ' || mail_list_rec.mail_addr;
                END LOOP;

                CLOSE mail_list_cur;
           end;

          v_body := v_body || v_l_feed || v_error_text;
          v_subject := v_error_text;
          x := x + 1;

          insert into error_log (session_user,
                                 sessionid,
                                 error_num,
                                 error_text
                                )
                      values    (sys_context('USERENV','SESSION_USER'),
                                 sys_context('USERENV','SESSIONID'),
                                 v_error_num,
                                 v_error_text
                                 );
           commit;


     end loop;



   if v_inform > 0
   then

     v_code := send(
                  p_from => DATABASE_NAME,
                  p_to => v_mail_list,
                  p_cc => NULL,
                  p_bcc => NULL,
                  p_subject => v_subject,
                  p_body => v_body,
                  p_smtp_host => 'mail.erp.mooreus.com',
                  p_attachment_data => NULL,
                  p_attachment_type => NULL,
                  p_attachment_file_name => NULL);
   end if;

 end;

end;




/

-- End DDL Extract of Trigger SYS.TRAP_ERROR

-- Begin DDL Extract of Trigger SYS.WATCH_EVENT_TRG
-- Extracted from DDW2 by SYSTEM
-- Extracted at 10:06:50, 01/08/2001

CREATE OR REPLACE TRIGGER SYS.WATCH_EVENT_TRG
  BEFORE
  ON SYS.
declare

  v_msg varchar2(2000) :=
          sysevent || ' attempted on ' ||
          DICTIONARY_OBJ_TYPE  || ' ' ||
          DICTIONARY_OBJ_OWNER || '.' ||
          DICTIONARY_OBJ_NAME  || ' by ' ||
          LOGIN_USER;

  mail_list_rec mail_list%ROWTYPE;
  v_mail_list varchar2(1000);
  v_code number;
  v_alert_level number;
  v_body varchar2(512);
  v_subject varchar(512);
  v_l_feed  varchar2(10) := chr(10);




  CURSOR mail_list_cur IS

       select *
       from mail_list
       where alert_level = v_alert_level;



begin

        v_alert_level := 1;

         insert into event_log (session_user,
                                 sessionid,
                                 sys_event,
                                 obj_owner,
                                 obj_name,
                                 obj_type
                                )
                      values    (LOGIN_USER,
                                 sys_context('USERENV','SESSIONID'),
                                 sysevent,
                                 DICTIONARY_OBJ_OWNER,
                                 DICTIONARY_OBJ_NAME,
                                 DICTIONARY_OBJ_TYPE
                                 );


          OPEN mail_list_cur;
                LOOP
                      FETCH mail_list_cur into mail_list_rec;
                      exit when mail_list_cur%NOTFOUND;

                     v_mail_list := v_mail_list || '  ' || mail_list_rec.mail_addr;
          END LOOP;

           CLOSE mail_list_cur;

           v_body := v_msg;
           v_subject := v_msg;

           v_code := send(
                  p_from => DATABASE_NAME,
                  p_to => v_mail_list,
                  p_cc => NULL,
                  p_bcc => NULL,
                  p_subject => v_subject,
                  p_body => v_body,
                  p_smtp_host => 'mail.erp.mooreus.com',
                  p_attachment_data => NULL,
                  p_attachment_type => NULL,
                  p_attachment_file_name => NULL);



end;

/

-- End DDL Extract of Trigger SYS.WATCH_EVENT_TRG
