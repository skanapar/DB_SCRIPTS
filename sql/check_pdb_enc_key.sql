set lines 200
col name format a30

 select name, (select nvl(max(key_id), '**NO KEY **') from v$encryption_keys) key_id,
           ( select (name) db_name from v$database) db_name
 from v$pdbs
/
