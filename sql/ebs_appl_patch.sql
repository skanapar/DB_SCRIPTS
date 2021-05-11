set line 150
column patch_name format a15
column applied_patch_id format 999999999
column patch_type format a18
select APPLIED_PATCH_ID, PATCH_NAME, PATCH_TYPE, SOURCE_CODE, CREATION_DATE, LAST_UPDATE_DATE, RAPID_INSTALLED_FLAG
 from applsys.ad_applied_patches 
 where PATCH_NAME = '&patch_id' 
order by creation_date desc
/
