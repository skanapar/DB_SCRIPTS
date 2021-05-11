select a.TS#, a.NAME, b.ENCRYPTIONALG, b.ENCRYPTEDTS, b.MASTERKEYID from v$tablespace a, V$ENCRYPTED_TABLESPACES b
where     a.ts# = b.ts#(+);
