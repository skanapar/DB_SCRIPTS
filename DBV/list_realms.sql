set lines 200
col name format a50
col audit_options format 999
col enabled format a10
SELECT ID#, NAME, REALM_TYPE, COMMON, AUDIT_OPTIONS, ENABLED FROM DVSYS.DBA_DV_REALM 
  WHERE AUDIT_OPTIONS = '1';
