BEGIN
   DBMS_REFRESH.MAKE (
      name => 'xfierroe.p2k_rg',
      list => 'xfierroe.mv_well_header',
      next_date => SYSDATE+10/24,
      interval => 'trunc(SYSDATE+1) + 3/24',
      implicit_destroy => TRUE); 
END;
