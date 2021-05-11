set lines 200
col realm_name format a50
col owner format a20
col object_name format a40
SELECT REALM_NAME, OWNER, OBJECT_NAME FROM DVSYS.DBA_DV_REALM_OBJECT
order by 2,3
/
