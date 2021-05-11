set lines 200
 col username format a30

select name, username, machine, count(9)
 from gv$session, v$database
 group by username, machine,name
/
