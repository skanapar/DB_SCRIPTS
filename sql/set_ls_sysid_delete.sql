create or replace procedure set_ls_sysid_delete( system_name_par in varchar2 )
as
-- eduardo fierro 01/2007

sysname_id_var number(5);
company_id_var number(5);
system_id_to number(5);
system_id_from number(5);

begin

select system_id into system_id_from from system 
	where system_name_code_id=
	(select system_name_code_id from code_system_name
		where system_name=system_name_par);
select system_name_code_id into sysname_id_var from code_system_name 
	where upper(system_name)='DELETE';
select company_id into company_id_var from company 
	where upper(company_name)='DELETE';
select system_id into system_id_to from system 
	where SYSTEM_NAME_CODE_ID=sysname_id_var 
	and COMPANY_ID=company_id_var;

update line_segment set system_id=system_id_to
	where system_id=system_id_from;
commit;

dbms_output.enable(buffer_size => NULL);
dbms_output.put_line('Changed all line segments in '||system_name_par||
	' system_id='||to_char(system_id_from)||
	', to system_id='||to_char(system_id_to)||' ''DELETE''');

end;
/
show errors
grant execute on set_ls_sysid_delete to intrepid_cenrw;
grant execute on set_ls_sysid_delete to baquerom;
