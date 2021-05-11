set verify off
DECLARE

-- ############## CURSORS

cursor c1 is
	select facility_id, feature_id, pwtype, bdone, ROWID from &&1
	where pwtype = '&&2' and bdone = 0;
layer_tab_rec c1%ROWTYPE;

cursor c2(facid varchar2) is
	select * from &2
	where facility_id = facid;
pwtype_tab_rec c2%ROWTYPE;

-- ############## VARIABLES

dat_tab varchar2(150);
feid integer;
salida utl_file.file_type;

-- ############## MAIN BODY

BEGIN

salida:=utl_file.fopen('/u01/app/oracle/sdeupdate','&1-&2-log','w');
utl_file.put_line(salida,'&1 - &2');
utl_file.put_line(salida,to_char(sysdate,'DD-MON-YY HH24:MI:SS'));
utl_file.put_line(salida,'__________________________________________________________________');
utl_file.put_line(salida,'NEW FEID'||chr(9)||chr(9)||'FEATURE_ID'||chr(9)||chr(9)||'FACILITY_ID');

OPEN c1;
LOOP
	FETCH c1 INTO layer_tab_rec;
	EXIT WHEN (c1%NOTFOUND);

	open c2(layer_tab_rec.facility_id);
	fetch c2 into pwtype_tab_rec;
	if c2%notfound then
		select feature_id_seq.nextval into feid from dual;
		insert into &2 (FEATURE_ID, FACILITY_ID)
			values (feid, layer_tab_rec.facility_id);
		update &1 set FEATURE_ID = feid, BDONE = 1
			where ROWID = layer_tab_rec.ROWID;
		utl_file.put_line(salida,'########'||chr(9)||chr(9)||feid||chr(9)||chr(9)||layer_tab_rec.facility_id);
--		dbms_output.put_line('Not found='||layer_tab_rec.facility_id);
	else
		update &1 set FEATURE_ID = pwtype_tab_rec.feature_id, BDONE = 1
			where ROWID = layer_tab_rec.ROWID;
		utl_file.put_line(salida,chr(9)||chr(9)||chr(9)||pwtype_tab_rec.feature_id||chr(9)||chr(9)||layer_tab_rec.facility_id);
--		dbms_output.put_line('Found=    '||layer_tab_rec.facility_id);
	end if;
	close c2;
	COMMIT; 
	utl_file.fflush(salida);
END LOOP; 
CLOSE c1; 
utl_file.put_line(salida,'_____________________________________________________________________');
utl_file.put_line(salida,to_char(sysdate,'DD-MON-YY HH24:MI:SS'));
utl_file.fclose(salida);
END sdeupdate; 
/
show errors
set verify on
