-- Description  : Displays a list of all temporary segments.

SET LINESIZE 500

SELECT username,
       count(extents),
	sum(blocks)*8*1024/1048576 Mb
FROM   V$TEMPSEG_USAGE 
GROUP BY username;
