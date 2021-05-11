BEGIN
  DBMS_OUTLN.create_outline(
    hash_value    => '&hash_value',
    child_number  => &child_number,
    category      => 'DEFAULT');
END;
/
