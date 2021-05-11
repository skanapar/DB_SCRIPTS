
CREATE PLUGGABLE DATABASE "&&PDBNAME"
        ADMIN USER "admin" IDENTIFIED BY "&&TDEPASS"
        STORAGE UNLIMITED
        TEMPFILE REUSE;
--        FILE_NAME_CONVERT='NONE';
alter pluggable database &&PDBNAME OPEN instances=all;
whenever sqlerror exit 99
alter session set container=&&PDBNAME;
      
administer key management set key force keystore identified by "&&TDEPASS" with backup ;
