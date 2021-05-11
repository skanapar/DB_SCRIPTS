column SQL_FULLTEXT format a260
set line 500
set pages 500
set trimout on
set trimspool on
SELECT SQL_ID, rtrim(sys.dbms_lob.substr(SQL_FULLTEXT,4000,1)) FROM V$SQL WHERE UPPER(PARSING_SCHEMA_NAME) = '&parsing_schema' 
--AND UPPER(MODULE) LIKE 'REALTIME%' 
ORDER BY ELAPSED_TIME DESC
/
