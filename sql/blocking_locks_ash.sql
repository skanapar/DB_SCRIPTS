SELECT  distinct a.sql_id ,a.inst_id,a.blocking_session,a.blocking_session_serial#,a.user_id,s.sql_text,a.module
FROM  GV$ACTIVE_SESSION_HISTORY a  ,gv$sql s
where a.sql_id=s.sql_id
and blocking_session is not null
and a.user_id <> 0 --  exclude SYS user 
and a.sample_time > sysdate - 2