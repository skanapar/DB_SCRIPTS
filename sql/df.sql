column name format a60
select FILE#, TS#, STATUS, ENABLED, BYTES/1048576 mb, NAME, CON_ID from v$datafile order by CON_ID, TS#, FILE#
/
