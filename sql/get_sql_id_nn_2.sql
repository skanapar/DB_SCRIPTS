COL my_sql_id NEW_V my_sql_id FOR A13;
SELECT sql_id my_sql_id, child_number
  FROM v$sql
 WHERE sql_text LIKE '%cust_id = TO_NUMBER(''&&nn.'')%'
   AND sql_text NOT LIKE '%FROM v$sql%';