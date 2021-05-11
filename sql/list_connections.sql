col username format a29
col machione format a40
select username, machine, count(9) from gv$session group by username,machine
/
