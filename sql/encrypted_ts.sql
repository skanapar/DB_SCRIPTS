select a.TS#, a.NAME, c.CONTENTS, b.ENCRYPTIONALG, b.ENCRYPTEDTS, b.MASTERKEYID, b.KEY_VERSION, b.STATUS, b.CON_ID from v$tablespace a, dba_tablespaces c, V$ENCRYPTED_TABLESPACES b
where
a.ts# = b.ts# and
a.name = c.tablespace_name
/
