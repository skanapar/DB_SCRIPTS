set line 10000
set trimspool on
set termout off
set head on
set pages 50000
spool pcdocs
select ITEM_ID, DOCUMENT_CLASS, BASIN, COUNTRY, TITLE, AREA, COUNTRY_ID, PC_COUNTRY, BASIN_ID, PC_BASIN, URL from filenet_mcountry
where DOCUMENT_CLASS = 'WW Exploration Reports' and upper(URL) like '%HOU_CS2^ODTWFNTC%'
union
select ITEM_ID, DOCUMENT_CLASS, BASIN, COUNTRY, TITLE, AREA, COUNTRY_ID, PC_COUNTRY, BASIN_ID, PC_BASIN, URL from filenet_mbasin
where DOCUMENT_CLASS = 'WW Exploration Reports' and upper(URL) like '%HOU_CS2^ODTWFNTC%'
/
spool off
