select MODULE, USERNAME, count(*) from db_logons where LOGON_TIME > sysdate-30 group by MODULE, USERNAME
/
