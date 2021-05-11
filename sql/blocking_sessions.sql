with locks as(
    select session_id,lock_type,
           mode_held,mode_requested,lock_id1,lock_id2,blocking_others
      from sys.dba_lock),
waiters as (
    select w.session_id waiting_session,
            h.session_id holding_session,
            w.lock_type lock_type,
            h.mode_held mode_held,
            w.mode_requested mode_requested,
            w.lock_id1,
            w.lock_id2
      from locks w, locks h
     where h.blocking_others =  'Blocking'
      and  h.mode_held      !=  'None'
      and  h.mode_held      !=  'Null'
      and  w.mode_requested !=  'None'
      and  w.lock_type       =  h.lock_type
      and  w.lock_id1        =  h.lock_id1
      and  w.lock_id2        =  h.lock_id2),
blockers as(
    select holding_session waiting_session, to_number(null) holding_session, 
           'None' lock_type, null mode_held, null mode_requested, 
           null lock_id1, null lock_id2
      from waiters
     minus
    select waiting_session waiting_session, to_number(null) holding_session, 
           'None' lock_type, null mode_held, null mode_requested, 
           null lock_id1, null lock_id2
      from waiters),
waiters_blockers as(
    select waiting_session,holding_session,lock_type,mode_held,mode_requested,lock_id1,lock_id2
      from waiters
     union all
    select waiting_session,holding_session,lock_type,mode_held,mode_requested,lock_id1,lock_id2
      from blockers),
lock_objects as(
    select session_id,cnt lock_obj_count,
           case when cnt = 1 then object_name
                else null end object_name,
           object_id,owner,object_type
      from(
        select session_id,count(distinct object_name) cnt,max(object_name) object_name,
               max(lo.object_id) object_id, max(ao.owner) owner,max(object_type) object_type
          from v$locked_object lo,sys.dba_objects ao
         where lo.object_id = ao.object_id
         group by session_id)),
wait_block_ses as(
select waiting_session,holding_session,lock_type,mode_held,mode_requested,
       s.username,s.osuser,s.CLIENT_INFO,s.CLIENT_IDENTIFIER,o.object_name,o.owner,o.object_id,module,o.object_type,o.lock_obj_count,
        decode(s.command,  
         0,null, 
         1,'CRE TAB', 
         2,'INSERT', 
         3,'SELECT', 
         4,'CRE CLUSTER', 
         5,'ALT CLUSTER', 
         6,'UPDATE', 
         7,'DELETE', 
         8,'DRP CLUSTER', 
         9,'CRE INDEX', 
         10,'DROP INDEX', 
         11,'ALT INDEX', 
         12,'DROP TABLE', 
         13,'CRE SEQ', 
         14,'ALT SEQ', 
         15,'ALT TABLE', 
         16,'DROP SEQ', 
         17,'GRANT', 
         18,'REVOKE', 
         19,'CRE SYN', 
         20,'DROP SYN', 
         21,'CRE VIEW', 
         22,'DROP VIEW', 
         23,'VAL INDEX', 
         24,'CRE PROC', 
         25,'ALT PROC', 
         26,'LOCK TABLE', 
         28,'RENAME', 
         29,'COMMENT', 
         30,'AUDIT', 
         31,'NOAUDIT', 
         32,'CRE DBLINK', 
         33,'DROP DBLINK', 
         34,'CRE DB', 
         35,'ALTER DB', 
         36,'CRE RBS', 
         37,'ALT RBS', 
         38,'DROP RBS', 
         39,'CRE TBLSPC', 
         40,'ALT TBLSPC', 
         41,'DROP TBLSPC', 
         42,'ALT SESSION', 
         43,'ALT USER', 
         44,'COMMIT', 
         45,'ROLLBACK', 
         46,'SAVEPOINT', 
         47,'PL/SQL EXEC', 
         48,'SET XACTN', 
         49,'SWITCH LOG', 
         50,'EXPLAIN', 
         51,'CRE USER', 
         52,'CRE ROLE', 
         53,'DROP USER', 
         54,'DROP ROLE', 
         55,'SET ROLE', 
         56,'CRE SCHEMA', 
         57,'CRE CTLFILE', 
         58,'ALTER TRACING', 
         59,'CRE TRIGGER', 
         60,'ALT TRIGGER', 
         61,'DRP TRIGGER', 
         62,'ANALYZE TAB', 
         63,'ANALYZE IX', 
         64,'ANALYZE CLUS', 
         65,'CRE PROFILE', 
         66,'DRP PROFILE', 
         67,'ALT PROFILE', 
         68,'DRP PROC', 
         69,'DRP PROC', 
         70,'ALT RESOURCE', 
         71,'CRE SNPLOG', 
         72,'ALT SNPLOG', 
         73,'DROP SNPLOG', 
         74,'CREATE SNAP', 
         75,'ALT SNAP', 
         76,'DROP SNAP', 
         79,'ALTER ROLE', 
         79,'ALTER ROLE', 
         85,'TRUNC TAB', 
         86,'TRUNC CLUST', 
         88,'ALT VIEW', 
         91,'CRE FUNC', 
         92,'ALT FUNC', 
         93,'DROP FUNC', 
         94,'CRE PKG', 
         95,'ALT PKG', 
         96,'DROP PKG', 
         97,'CRE PKG BODY', 
         98,'ALT PKG BODY', 
         99,'DRP PKG BODY', 
         to_char(s.command)) command
  from waiters_blockers wb, v$session s,
       lock_objects o
 where s.sid = wb.waiting_session
   and o.session_id(+) = wb.waiting_session
  )
select 
       decode(level,1,1,power(level*3,2)) padding,level lvl,waiting_session,holding_session,
       username,osuser,CLIENT_INFO,CLIENT_IDENTIFIER,
       object_name,     
       object_id,owner,module,object_type
  from wait_block_ses 
 start with holding_session is null
 connect by prior waiting_session = holding_session
/

