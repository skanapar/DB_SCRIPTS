tti "Auditing Initialisation Parameters:"
select name || '=' || value PARAMETER
from   sys.v_$parameter where name like '%audit%'
/

tti "Statement Audits Enabled on this Database"
column user_name format a10
column audit_option format a40
select *
from   sys.dba_stmt_audit_opts
/

tti "Privilege Audits Enabled on this Database"
select * from dba_priv_audit_opts
/

tti "Object Audits Enabled on this Database"
select (owner ||'.'|| object_name) object_name,
       alt, aud, com, del, gra, ind, ins, loc, ren, sel, upd, ref, exe
from   dba_obj_audit_opts
where  alt != '-/-' or aud != '-/-'
   or  com != '-/-' or del != '-/-'
   or  gra != '-/-' or ind != '-/-'
   or  ins != '-/-' or loc != '-/-'
   or  ren != '-/-' or sel != '-/-'
   or  upd != '-/-' or ref != '-/-'
   or  exe != '-/-'
/

tti "Default Audits Enabled on this Database"
select * from all_def_audit_opts
/
