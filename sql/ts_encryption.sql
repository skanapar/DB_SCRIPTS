select b.con_id, a.TS#, a.NAME, b.ENCRYPTIONALG, b.ENCRYPTEDTS, b.MASTERKEYID
from v$tablespace a, V$ENCRYPTED_TABLESPACES b
where   a.con_id = b.con_id and a.ts# = b.ts#(+)
order by 1
/