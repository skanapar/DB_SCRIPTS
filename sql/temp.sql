set pages 1000
 set line 200
 select a.TS#, a.NAME, b.ENCRYPTIONALG, b.ENCRYPTEDTS, b.MASTERKEYID, b.KEY_VERSION, b.STATUS, b.CON_ID 
from v$tablespace a, V$ENCRYPTED_TABLESPACES b   
where     a.ts# = b.ts#(+)
and a.con_id=b.con_id(+);
