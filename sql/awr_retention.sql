select * from dba_hist_wr_control where dbid = (select dbid from v$database)
/
