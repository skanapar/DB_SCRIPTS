begin
for rec in ( select file_name, greatest(1048576*1024*30, bytes) new_bytes
            from dba_temp_files )
loop
dbms_output.put_line ('alter database tempfile '||rec.file_name||'  resize '||rec.new_bytes);
execute immediate 'alter database tempfile '''||rec.file_name||'''  resize '||rec.new_bytes;
end loop;
end;
/
