BEGIN
  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'HR'
     ,TabName        => 'EMPLOYEES'
    ,Method_Opt        => 'FOR ALL COLUMNS SIZE AUTO '
    ,Degree            => 4
    ,Cascade           => TRUE
    ,No_Invalidate     => FALSE);
END;
/

