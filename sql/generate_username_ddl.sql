-- http://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:494205100346718343

undef v_username

set long 100000
set verify off

declare
v_ddl     varchar2(4000) ;
c_crlf    varchar2(2)    := chr(10)||chr(13) ;
c_exec    varchar2(1)    := '/' ;
c_trimchr varchar2(10)   := chr(10)||chr(32) ;
c_lf      varchar2(1)    := chr(10) ;

begin
begin
select dbms_metadata.get_ddl( 'USER', '&&v_username' ) 
into v_ddl
from dual
;
--dbms_output.put_line(v_ddl||c_crlf||c_exec) ;
dbms_output.put_line(c_lf||ltrim(v_ddl,c_trimchr)||c_crlf||c_exec) ;
exception
when others then 
null;
end ;
v_ddl := NULL ;

begin
select dbms_metadata.get_granted_ddl( 'TABLESPACE_QUOTA', '&&v_username' )
into v_ddl
from dual
;
--dbms_output.put_line(v_ddl||c_crlf||c_exec) ;
dbms_output.put_line(c_crlf||ltrim(replace(v_ddl,'  DECLARE ',c_exec||c_crlf||'DECLARE '),c_lf||'/')||c_crlf||c_exec) ;
exception
when others then 
null;
end ;
v_ddl := NULL ;

begin
select dbms_metadata.get_granted_ddl( 'SYSTEM_GRANT', '&&v_username' )
into v_ddl
from dual
;
--dbms_output.put_line(v_ddl||c_crlf||c_exec) ;
dbms_output.put_line(c_crlf||ltrim(replace(v_ddl,'  GRANT ',c_exec||c_crlf||'GRANT '),c_lf||'/')||c_crlf||c_exec) ;
exception
when others then 
null;
end ;
v_ddl := NULL ;

begin
select dbms_metadata.get_granted_ddl( 'OBJECT_GRANT', '&&v_username' )
into v_ddl
from dual
;
--dbms_output.put_line(v_ddl||c_crlf||c_exec) ;
dbms_output.put_line(c_crlf||ltrim(replace(v_ddl,'  GRANT ',c_exec||c_crlf||'GRANT '),c_lf||'/')||c_crlf||c_exec) ;
exception
when others then 
null;
end ;
v_ddl := NULL ;

begin
select dbms_metadata.get_granted_ddl( 'ROLE_GRANT', '&&v_username' )
into v_ddl
from dual
;
dbms_output.put_line(c_crlf||ltrim(replace(v_ddl,'   GRANT ',c_exec||c_crlf||'GRANT '),c_lf||'/')||c_crlf||c_exec) ;
exception
when others then 
null;
end ;
v_ddl := NULL ;

begin
select dbms_metadata.get_granted_ddl( 'DEFAULT_ROLE', '&&v_username' )
into v_ddl
from dual
;
dbms_output.put_line(c_lf||ltrim(v_ddl,c_trimchr)||c_crlf||c_exec) ;
exception
when others then 
null;
end ;
v_ddl := NULL ;

end ;
/

clear buffer