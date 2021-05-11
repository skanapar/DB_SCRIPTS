set linesize 132
set pagesize 100
select tablespace_name,initial_extent,next_extent,min_extents,max_extents,status,extent_management,logging
from dba_tablespaces;
