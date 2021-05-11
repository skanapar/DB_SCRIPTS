set serverout on
set time on
set termout on
declare
  m    number;
  t    number;
  e    number;
  c    clob;
  i    number := 0;

begin

dbms_output.enable(5000);
/* e   :=  dbms_metadata.session_transform;
  dbms_metadata.set_transform_param   (e, 'REF_CONSTRAINTS'     ,  false   );
  dbms_metadata.set_transform_param   (e, 'CONSTRAINTS_AS_ALTER',  true    );
  dbms_metadata.set_transform_param   (e, 'CONSTRAINTS'         ,  true    );
  dbms_metadata.set_transform_param   (e, 'FORCE'               ,  true    );
*/

  m   :=  dbms_metadata.open('SCHEMA_EXPORT');
  dbms_metadata.set_filter            (m, 'SCHEMA'              , 'FINANCIALS'  );

  t   :=  dbms_metadata.add_transform (m, 'DDL');
  dbms_metadata.set_transform_param   (t, 'PRETTY'              ,  true    );
  dbms_metadata.set_transform_param   (t, 'SQLTERMINATOR'       ,  true    );
/*  dbms_metadata.set_filter            (m, 'EXCLUDE_PATH_EXPR'   , 'in ('   ||
                                            '''GRANT''          ,' || 
                                            '''SYNONYM''        ,' || 
                                            '''STATISTICS''     ,' || 
                                            '''COMMENT''         ' ||
                                            ')');
*/

  loop
    c   :=  dbms_metadata.fetch_clob(m);
    exit when c is null;
    insert into efierro_dba.usl_metadata values (c, i);
    commit;
    i := i+1;
  end loop;

if c is null
then
    dbms_output.put_line('Nothing inserted');
else
    dbms_output.put_line('Inserted '||i||' records.');
end if;

  dbms_metadata.close(m);

end;
/

