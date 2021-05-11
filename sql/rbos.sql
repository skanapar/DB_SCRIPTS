SELECT
   p1 file#,
   p2 block#,
   p3 class#
FROM
   v$session_wait
WHERE
   event like '%by other%'
/
