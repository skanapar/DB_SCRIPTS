FOR x IN (SELECT * FROM user_tables)
LOOP
  EXECUTE IMMEDIATE 'GRANT SELECT ON ' || x.table_name || ' TO <<someone>>';
END LOOP;