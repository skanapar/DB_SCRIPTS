--CONNECT c##dbv_owner_root@&pdb
set serveroutput on
begin
for rec in (select username from dba_users where username like '%.%')
loop
begin
dbms_macadm.add_auth_to_realm(realm_name => 'PEOPLESOFT_SCHEMA', grantee => '"'||rec.username||'"', rule_set_name => '', auth_options => DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT);
exception
when others then 
dbms_output.put_line(SQLERRM);
end;



end loop;
end;
/
