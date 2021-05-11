column VALUE format a50
column NAME format a30
select INST_ID, NAME, VALUE, ISDEFAULT, ISMODIFIED from gv$parameter where name like '%&str%'
/
