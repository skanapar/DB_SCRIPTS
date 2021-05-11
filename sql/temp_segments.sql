-- Description  : Displays a list of all temporary segments.

SET LINESIZE 500

SELECT owner,
       Trunc(Sum(bytes)/1024) Kb
FROM   dba_segments 
WHERE  segment_type = 'TEMPORARY'
GROUP BY owner;
