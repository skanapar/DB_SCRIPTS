set linesize 300
column name format a30
column masterkeyid_base64 format a30

col key_id format a52
col CREATION_TIME format a36
col origin format a15
col CREATOR_DBNAME format a15
col CREATOR_PDBNAME format a15
col ACTIVATION_TIME format a36
col ACTIVATING_DBNAME format a18
col ACTIVATING_PDBNAME format a19


select con_name , ts#, name as ts_name,utl_raw.cast_to_varchar2
( utl_encode.base64_encode('01'||substr(mkeyid,1,4))) ||
utl_raw.cast_to_varchar2( utl_encode.base64_encode
(substr(mkeyid,5,length(mkeyid)))) masterkeyid_base64
FROM (select p.name as con_name, t.ts# , t.name, RAWTOHEX(x.mkid) mkeyid
from v$tablespace t, x$kcbtek x, v$pdbs p
where t.ts#=x.ts# and p.con_id=t.con_id and x.con_id=p.con_id)
order by con_name, ts#;

select utl_raw.cast_to_varchar2( utl_encode.base64_encode('01'||substr(mkeyid,1,4))) || utl_raw.cast_to_varchar2( utl_encode.base64_encode(substr(mkeyid,5,length(mkeyid)))) masterkeyid_base64 FROM (select RAWTOHEX(mkid) mkeyid from x$kcbdbk);

select key_id, con_id, origin, creation_time, creator_dbname, creator_pdbname, activation_time, activating_dbname, activating_pdbname from v$encryption_keys;

@sp

select utl_raw.cast_to_varchar2( utl_encode.base64_encode('01'||substr(mkeyid,1,4))) || utl_raw.cast_to_varchar2( utl_encode.base64_encode(substr(mkeyid,5,length(mkeyid)))) masterkeyid_base64 FROM (select RAWTOHEX(mkid) mkeyid from x$kcbdbk);

