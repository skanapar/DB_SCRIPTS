--alter database default temporary tablespace dba_temp
--/
--drop tablespace temp including contents and datafiles
--/
CREATE TEMPORARY TABLESPACE temp
tempfile
'/fs-a01-a/databases/uusl3na/temp-01.dbf' size 30G,
'/fs-a01-b/databases/uusl3na/temp-02.dbf' size 30G,
'/fs-a01-c/databases/uusl3na/temp-03.dbf' size 30G,
'/fs-a01-d/databases/uusl3na/temp-04.dbf' size 30G,
'/fs-b01-a/databases/uusl3na/temp-05.dbf' size 30G,
'/fs-b01-b/databases/uusl3na/temp-06.dbf' size 30G,
'/fs-b01-c/databases/uusl3na/temp-07.dbf' size 30G,
'/fs-b01-d/databases/uusl3na/temp-08.dbf' size 30G
/
alter database default temporary tablespace temp
/
